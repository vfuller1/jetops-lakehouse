import argparse
import json
import os
from pathlib import Path

import jsonref
import requests
from azure.ai.projects import AIProjectClient
from azure.ai.projects.models import (
    OpenApiFunctionDefinition,
    OpenApiProjectConnectionAuthDetails,
    OpenApiProjectConnectionSecurityScheme,
    OpenApiTool,
    PromptAgentDefinition,
)
from azure.identity import AzureCliCredential


DEFAULT_PROJECT_ENDPOINT = (
    'https://jetops-foundry-dev-41497b8e.services.ai.azure.com/api/projects/fleet-maintenance-copilot'
)
DEFAULT_AGENT_NAME = 'fleet-maintenance-copilot-agent'
DEFAULT_MODEL_DEPLOYMENT = 'gpt-4-1-mini'
DEFAULT_CONNECTION_NAME = 'jetops-gold-api-key'
DEFAULT_OPENAPI_URL = (
    'https://jetops-gold-api.blackpebble-8c1a9729.eastus2.azurecontainerapps.io/api/gold/openapi.json'
)
DEFAULT_OUTPUT_PATH = Path('foundry/agent_version_comparison.json')

DEFAULT_QUERIES = [
    'How many aircraft currently have critical issues? Use the maintenance KPI API.',
    'Which aircraft should maintenance control review first this morning? Use the maintenance KPI API and explain the triage order.',
    'Which components had the highest unscheduled maintenance pressure over the last 7 days? Use the maintenance KPI API and cite the lookback window.',
]

V2_INSTRUCTIONS = """You are the Fleet Maintenance Copilot for JetOps maintenance control.

Use the Gold KPI API as the system of record for operational answers.

Required behavior:
1. Always call the API before answering operational questions.
2. Prioritize aircraft in AOG status first, then Critical severity, then High severity, then remaining open issues.
3. For triage questions, combine executive KPIs, fleet watchlist, and component reliability when useful.
4. When a question depends on a time window, state the exact lookback window returned by the tool.
5. Keep answers concise and operational. Prefer short sections titled Summary, Evidence, and Recommended Action.
6. Do not invent counts, statuses, or rankings that the API did not return.
7. If the data is insufficient for a precise answer, say what is missing and what tool call would resolve it.
"""


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('--project-endpoint', default=DEFAULT_PROJECT_ENDPOINT)
    parser.add_argument('--agent-name', default=DEFAULT_AGENT_NAME)
    parser.add_argument('--model-deployment', default=DEFAULT_MODEL_DEPLOYMENT)
    parser.add_argument('--connection-name', default=DEFAULT_CONNECTION_NAME)
    parser.add_argument('--openapi-url', default=DEFAULT_OPENAPI_URL)
    parser.add_argument('--api-key', default=os.environ.get('JETOPS_API_KEY'))
    parser.add_argument('--output', default=str(DEFAULT_OUTPUT_PATH))
    return parser.parse_args()


def load_openapi_spec(openapi_url: str, api_key: str) -> dict:
    response = requests.get(openapi_url, headers={'x-api-key': api_key}, timeout=60)
    response.raise_for_status()
    return jsonref.loads(response.text)


def invoke_agent(openai_client, agent_name: str, version: str, query: str) -> str:
    agent_reference = {
        'type': 'agent_reference',
        'name': agent_name,
        'version': version,
    }
    response = openai_client.responses.create(
        input=query,
        extra_body={'agent_reference': agent_reference},
    )
    return response.output_text


def invoke_agent_capture(openai_client, agent_name: str, version: str, query: str) -> dict:
    try:
        return {
            'status': 'ok',
            'answer': invoke_agent(openai_client, agent_name, version, query),
        }
    except Exception as exc:  # pylint: disable=broad-except
        return {
            'status': 'error',
            'answer': str(exc),
        }


def main():
    args = parse_args()
    if not args.api_key:
        raise RuntimeError('Provide JETOPS_API_KEY or --api-key so the protected OpenAPI document can be fetched.')

    project = AIProjectClient(
        endpoint=args.project_endpoint,
        credential=AzureCliCredential(),
    )
    openai_client = project.get_openai_client()
    connection = project.connections.get(args.connection_name)
    openapi_spec = load_openapi_spec(args.openapi_url, args.api_key)

    api_tool = OpenApiTool(
        openapi=OpenApiFunctionDefinition(
            name='jetops_gold_kpi_api',
            spec=openapi_spec,
            description='Retrieve fleet maintenance KPIs, trends, and watchlist data from the JetOps Gold API.',
            auth=OpenApiProjectConnectionAuthDetails(
                security_scheme=OpenApiProjectConnectionSecurityScheme(
                    project_connection_id=connection.id,
                )
            ),
        )
    )

    created_version = project.agents.create_version(
        agent_name=args.agent_name,
        definition=PromptAgentDefinition(
            model=args.model_deployment,
            instructions=V2_INSTRUCTIONS,
            tools=[api_tool],
        ),
    )

    versions = sorted(
        [str(agent.version) for agent in project.agents.list_versions(agent_name=args.agent_name)],
        key=int,
    )
    if len(versions) < 2:
        raise RuntimeError(f'Expected at least two agent versions for {args.agent_name}, found {versions}.')

    baseline_version = versions[-2]
    comparison_version = str(created_version.version)
    comparison = []
    for query in DEFAULT_QUERIES:
        baseline_answer = invoke_agent_capture(openai_client, args.agent_name, baseline_version, query)
        comparison_answer = invoke_agent_capture(openai_client, args.agent_name, comparison_version, query)
        comparison.append(
            {
                'query': query,
                'version_1': {'version': baseline_version, **baseline_answer},
                'version_2': {'version': comparison_version, **comparison_answer},
            }
        )

    output = {
        'agent_name': args.agent_name,
        'connection_name': args.connection_name,
        'model_deployment': args.model_deployment,
        'baseline_version': baseline_version,
        'comparison_version': comparison_version,
        'queries': comparison,
    }

    output_path = Path(args.output)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(json.dumps(output, indent=2), encoding='utf-8')
    print(json.dumps(output, indent=2))


if __name__ == '__main__':
    main()
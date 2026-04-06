# Fleet Maintenance Copilot Setup

This document wires the first Azure AI Foundry project to the Gold KPI API instead of to storage directly.

## Provisioned Project

- Foundry account: `jetops-foundry-dev-41497b8e`
- Foundry project: `fleet-maintenance-copilot`
- Location: `eastus2`
- Project ARM ID: `/subscriptions/41497b8e-aaf1-4a1d-9f43-7ebf6213b955/resourceGroups/rg-herbalife-dev-core/providers/Microsoft.CognitiveServices/accounts/jetops-foundry-dev-41497b8e/projects/fleet-maintenance-copilot`
- Project endpoint: `https://jetops-foundry-dev-41497b8e.services.ai.azure.com/api/projects/fleet-maintenance-copilot`

## API Contract For Foundry

Run the Flask API and expose this OpenAPI document to Foundry:

- `https://jetops-gold-api.blackpebble-8c1a9729.eastus2.azurecontainerapps.io/api/gold/openapi.json`

The Gold API is now protected with the `x-api-key` header. The matching Foundry project connection is:

- `jetops-gold-api-key`

Core tool endpoints:

- `GET /api/gold/kpis/executive`
- `GET /api/gold/kpis/daily-operations?days=14`
- `GET /api/gold/kpis/component-reliability?days=7&limit=20`
- `GET /api/gold/kpis/fleet-watchlist?limit=50`

## Recommended Copilot Instructions

Use the Gold KPI API as the system of record for operational answers.

Rules:

1. Use `executive` for current fleet rollup questions.
2. Use `daily-operations` for trend questions.
3. Use `component-reliability` for component pressure and repeat-issue questions.
4. Use `fleet-watchlist` for aircraft prioritization and urgent maintenance review.
5. Do not answer from raw assumptions when the API can provide the answer.
6. Treat the API as authenticated infrastructure and route calls through the Foundry project connection instead of anonymous access.

## First Question Set To Validate

- Which stations have the most AOG pressure right now?
- Which components had the highest unscheduled maintenance pressure over the last 7 days?
- Which aircraft should maintenance control review first this morning?
- Is open-event backlog trending up or down over the last 14 days?

## Protected OpenAPI Wiring

The OpenAPI document now advertises an API key security scheme:

- header name: `x-api-key`
- Foundry auth type: `project_connection`
- Foundry connection category: `CustomKeys`

When you recreate the OpenAPI tool in code, use `OpenApiKeyAuthDetails(project_connection_id=...)` and fetch the OpenAPI document with the same `x-api-key` header.

## Agent Versioning

Use [scripts/manage_foundry_agent_versions.py](c:/LocalRepo/jetops-lakehouse-1/scripts/manage_foundry_agent_versions.py) to:

- create a new version of `fleet-maintenance-copilot-agent`
- attach the protected Gold API tool through `jetops-gold-api-key`
- compare the latest two versions on a fixed triage question set
- write the comparison artifact to `foundry/agent_version_comparison.json`

## Custom Domain Prerequisites

The Container App does not yet have a customer-owned DNS name attached. To bind a business-friendly stable URL, use a subdomain and a managed certificate.

- current app FQDN: `jetops-gold-api.blackpebble-8c1a9729.eastus2.azurecontainerapps.io`
- domain verification value: `04D7C5DAB4DC3AE4CFA9135B53B79113F29A13E9E4B52731A144C177E8C84C84`

Recommended DNS records for a subdomain such as `api.<your-domain>`:

- `CNAME api -> jetops-gold-api.blackpebble-8c1a9729.eastus2.azurecontainerapps.io`
- `TXT asuid.api -> 04D7C5DAB4DC3AE4CFA9135B53B79113F29A13E9E4B52731A144C177E8C84C84`

After the records exist, add the custom domain to the Container App and issue a managed certificate in the Container Apps environment.
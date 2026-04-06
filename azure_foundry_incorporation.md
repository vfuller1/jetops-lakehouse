# Azure AI Foundry Incorporation

This repo should use Azure Databricks for the medallion pipeline and Azure AI Foundry as the AI application layer on top of curated data, not as a replacement for Bronze, Silver, Gold, or job orchestration.

## Recommended Role Of Foundry Here

Use Foundry after Gold for:
- a maintenance operations copilot grounded on Gold KPI marts and fleet watchlists
- summarization of open maintenance risk by station, component, and aircraft
- predictive maintenance workflows that consume curated features from Silver and Gold
- evaluation, tracing, and prompt iteration for AI-powered operational assistants

Do not use Foundry for:
- raw ingestion from Event Hubs
- Bronze or Silver data engineering
- Delta table orchestration
- replacing Databricks notebook jobs

## Best First Incorporation Path

1. Keep Databricks as the system that produces curated maintenance data.
2. Treat Gold marts as the business-facing serving layer for Foundry.
3. Create an Azure AI Foundry project for the maintenance assistant use case.
4. Start with a prompt or hosted agent that answers questions like:
   - Which stations have the most AOG aircraft right now?
   - Which components had the highest unscheduled event volume over the last 7 days?
   - Which aircraft need immediate maintenance attention?
5. Ground that agent on curated outputs, not raw records.

## Practical Integration Options

### Option 1: Gold-As-API

Expose Gold outputs through an API or scheduled query layer. Foundry agents call the API to answer operational questions.

Best for:
- low-latency answers
- controlled query patterns
- operational copilots

### Option 2: Gold Snapshot To Knowledge Index

Export selected Gold summaries and fleet watchlists into a search index or other retrieval layer used by Foundry.

Best for:
- narrative Q and A
- summarized operations briefings
- knowledge-grounded copilots

### Option 3: Predictive Maintenance Loop

Use Databricks to engineer features and train models. Use Foundry to wrap those predictions in an agent experience, evaluation workflow, and business-facing interface.

Best for:
- failure forecasting
- maintenance prioritization
- technician or dispatcher copilots

## Suggested Near-Term Roadmap

1. Build and keep the Databricks Bronze, Silver, Gold chain scheduled.
2. Define one Foundry use case: maintenance operations copilot.
3. Decide the serving contract for Foundry: API access or indexed Gold summaries.
4. Create a Foundry project and deploy a first model.
5. Build a simple agent grounded on Gold outputs.
6. Evaluate the agent with realistic maintenance questions before broader rollout.

## Recommended First Foundry Use Case

Start with a fleet maintenance copilot backed by Gold marts:
- `daily_operations` for trend and backlog questions
- `component_reliability` for component pressure questions
- `fleet_status_snapshot` for latest aircraft status questions

That is the cleanest way to incorporate Foundry into this repo without destabilizing the lakehouse pipeline.

## Provisioned Non-Hosted Foundry Project

The first Foundry project is now provisioned without hosted-agent infrastructure.

- Resource group: `rg-herbalife-dev-core`
- Foundry account: `jetops-foundry-dev-41497b8e`
- Foundry project: `fleet-maintenance-copilot`
- Location: `eastus2`
- Foundry account ARM ID: `/subscriptions/41497b8e-aaf1-4a1d-9f43-7ebf6213b955/resourceGroups/rg-herbalife-dev-core/providers/Microsoft.CognitiveServices/accounts/jetops-foundry-dev-41497b8e`
- Foundry project ARM ID: `/subscriptions/41497b8e-aaf1-4a1d-9f43-7ebf6213b955/resourceGroups/rg-herbalife-dev-core/providers/Microsoft.CognitiveServices/accounts/jetops-foundry-dev-41497b8e/projects/fleet-maintenance-copilot`

Project endpoint format for SDK and tool wiring:

- `https://jetops-foundry-dev-41497b8e.services.ai.azure.com/api/projects/fleet-maintenance-copilot`

This setup intentionally avoids hosted-agent capability so the first cost surface is limited to the Foundry account and project themselves, plus any model deployments you add later.

## Gold KPI API Layer

The serving layer for Foundry is now the Gold KPI Flask API in `app/app.py` with the following endpoints:

- `GET /api/gold/health`
- `GET /api/gold/metadata`
- `GET /api/gold/openapi.json`
- `GET /api/gold/kpis/executive`
- `GET /api/gold/kpis/daily-operations?days=14`
- `GET /api/gold/kpis/component-reliability?days=7&limit=20`
- `GET /api/gold/kpis/fleet-watchlist?limit=50`

The API reads Databricks-produced JSON snapshots from ADLS Gen2 and is the cleanest contract for the first Foundry copilot.

## How Foundry Is Wired To The API

Use the OpenAPI document exposed by the running service:

- `http://<your-api-host>:5000/api/gold/openapi.json`

This gives you a tool surface Foundry can consume without giving the model direct access to raw or Silver data. The copilot should answer questions by calling this API, not by querying storage directly.

The snapshots are written by the Gold notebook under:

- `gold/jetops/maintenance_kpis_api/executive_kpis`
- `gold/jetops/maintenance_kpis_api/metadata`
- `gold/jetops/maintenance_kpis_api/daily_operations`
- `gold/jetops/maintenance_kpis_api/component_reliability`
- `gold/jetops/maintenance_kpis_api/fleet_status_snapshot`

## What Hosted Agents Would Add

If you turn on hosted-agent capability later, the Azure resource and cost surface expands beyond this non-hosted setup.

Always-added or commonly-added resources from the hosted-agent quickstart path:

- Foundry project: consumption-based Foundry pricing
- Model deployment: model-inference cost in Foundry
- Azure Container Registry: container image storage, typically Basic tier in the quickstart
- Application Insights: pay-as-you-go telemetry and monitoring cost through Azure Monitor
- Log Analytics workspace: log ingestion and retention surface for observability
- Managed identity: no direct resource cost, but required for secure access patterns

Hosted-agent specific platform/runtime considerations from the docs:

- Managed hosting runtime billing is enabled during preview no earlier than April 1, 2026
- Hosted agents run as containerized code on Agent Service, so you also take on image build and registry lifecycle
- Published hosted agents get a distinct agent identity, so downstream Azure permissions must be reassigned from the project identity to the agent identity

If you choose the more explicit capability-host route for standard agent setup, you also add or depend on:

- Account-level capability host
- Azure Cosmos DB connection for thread storage
- Azure Storage connection for file storage
- Azure AI Search connection for vector store data

That is why the first project here was created without hosted agents: it keeps cost, RBAC, and operational complexity low while the API contract and copilot behavior are still being shaped.
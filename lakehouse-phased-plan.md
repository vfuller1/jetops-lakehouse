# Phased Plan for Building a Lakehouse (Development/Training)

This document outlines a clear, actionable phased plan for building your Lakehouse in a development or training environment, including a dedicated data input strategy.

---

## Phase 1: Foundation & Environment Setup
- Select or create an Azure subscription and resource group for development.
- Deploy core networking: VNets, subnets, and NSGs.
- Set up storage: Deploy ADLS Gen2 (Data Lake).
- Deploy Databricks workspace for processing.
- Set up Event Hub for streaming data.
- Configure Terraform state storage (e.g., Azure Storage Account).
- Establish monitoring and logging (Azure Monitor, Log Analytics).

## Phase 2: Data Input Phase
- Identify and document all data sources (batch, streaming, APIs).
- Set up secure connections to source systems.
- Define data contracts and formats.
- Schedule or trigger data extractions as needed.

**Outcome:** Data sources are connected and ready for ingestion.

## Phase 3: Ingestion Layer
- Build batch ingestion pipelines (e.g., ADF, Databricks jobs).
- Build streaming ingestion pipelines (Event Hub → Databricks).
- (Optional) Deploy Azure Function to generate synthetic streaming data.
- Land all raw data in the Bronze layer.

**Outcome:** Live data flowing into the Lakehouse.

## Phase 4: Transformation Layer
- Clean and validate data in Silver layer (Databricks notebooks/jobs).
- Apply data quality and conformance rules.
- Model and conform key entities (customer, product, etc.).
- Create Gold business tables for analytics.
- Optimize Delta Lake partitions for performance.

**Outcome:** Analytics-ready data.

## Phase 5: Governance & Security
- Enable data catalog and lineage (e.g., Azure Purview).
- Apply sensitivity labels and data retention policies.
- Set up RBAC and access controls.
- Monitor access and usage patterns.

**Outcome:** Enterprise compliance readiness.

## Phase 6: Analytics & AI Enablement
- Engineer features for ML (Databricks/MLflow).
- Train and register ML models (e.g., churn, recommendations).
- Set up batch scoring or real-time inference pipelines.
- Write results to Gold tables.
- Build dashboards and BI reports (Power BI, etc.).

**Outcome:** Business intelligence and predictive capability.

## Phase 7: Self-Service & Optimization
- Enable governed self-service BI for users.
- Review and optimize cost, performance, and security.
- Document architecture, data flows, and operational procedures.

**Outcome:** Sustainable, user-friendly, and optimized Lakehouse platform.

---

## Example Terraform Outputs (from deployment)

```
aks_cluster_name = "aks-aviator-core"
aks_control_plane_fqdn = "aviatorcore-p3wl4qvp.hcp.eastus2.azmk8s.io"
aviator_app_identity_client_id = "bb72c2e2-d4a8-4d63-910a-4ee7272c4d00"
aviator_app_identity_resource_id = "/subscriptions/41497b8e-aaf1-4a1d-9f43-7ebf6213b955/resourceGroups/rg-aviator-core-prod/providers/Microsoft.ManagedIdentity/userAssignedIdentities/aviator-app-identity"
hub_vnet_id = "/subscriptions/41497b8e-aaf1-4a1d-9f43-7ebf6213b955/resourceGroups/rg-aviator-core-prod/providers/Microsoft.Network/virtualNetworks/vnet-hub-aviator"
resource_group_name = "rg-aviator-core-prod"
herbalife_databricks_workspace_id = "/subscriptions/41497b8e-aaf1-4a1d-9f43-7ebf6213b955/resourceGroups/rg-herbalife-dev-core/providers/Microsoft.Databricks/workspaces/databricks-herbalife-dev"
herbalife_databricks_workspace_name = "databricks-herbalife-dev"
herbalife_eventhub_namespace_id = "/subscriptions/41497b8e-aaf1-4a1d-9f43-7ebf6213b955/resourceGroups/rg-herbalife-dev-core/providers/Microsoft.EventHub/namespaces/eh-herbalife-dev"
herbalife_eventhub_namespace_name = "eh-herbalife-dev"
herbalife_log_analytics_workspace_id = "/subscriptions/41497b8e-aaf1-4a1d-9f43-7ebf6213b955/resourceGroups/rg-herbalife-dev-core/providers/Microsoft.OperationalInsights/workspaces/law-herbalife-dev"
herbalife_log_analytics_workspace_name = "law-herbalife-dev"
herbalife_storage_account_id = "/subscriptions/41497b8e-aaf1-4a1d-9f43-7ebf6213b955/resourceGroups/rg-herbalife-dev-core/providers/Microsoft.Storage/storageAccounts/stherbalifedev001"
herbalife_storage_account_name = "stherbalifedev001"
rycrawl_test_server_public_ip = "20.7.51.208"

# Lakehouse containers
herbalife_raw_container_name = "raw"
herbalife_bronze_container_name = "bronze"
herbalife_silver_container_name = "silver"

---

### Resource Purpose and Phase Mapping

| Resource Output                        | Purpose/Usage                                      | Phase(s)                          |
|----------------------------------------|----------------------------------------------------|------------------------------------|
| aks_cluster_name, aks_control_plane_fqdn | Kubernetes cluster for compute/workloads            | 1 (Foundation), 6 (AI/Analytics)   |
| aviator_app_identity_client_id, aviator_app_identity_resource_id | Managed identity for secure access                  | 1 (Foundation), 5 (Governance)     |
| hub_vnet_id                            | Core networking, secure connectivity                | 1 (Foundation)                     |
| resource_group_name                    | Resource grouping and management                    | 1 (Foundation)                     |
| herbalife_storage_account_id, herbalife_storage_account_name | ADLS Gen2 storage for data lakehouse                | 1 (Foundation), 3 (Ingestion)      |
| herbalife_databricks_workspace_id, herbalife_databricks_workspace_name | Data processing, analytics, ML                      | 1 (Foundation), 4 (Transformation), 6 (AI/Analytics) |
| herbalife_eventhub_namespace_id, herbalife_eventhub_namespace_name | Streaming data ingestion                             | 1 (Foundation), 3 (Ingestion)      |
| herbalife_log_analytics_workspace_id, herbalife_log_analytics_workspace_name | Monitoring and logging                              | 1 (Foundation), 5 (Governance)     |
| rycrawl_test_server_public_ip           | Demo/test server for training or sample workloads   | 1 (Foundation), Demo/Training      |
| herbalife_raw_container_name            | Raw data landing zone (Bronze layer)               | 3 (Ingestion)                      |
| herbalife_bronze_container_name         | Processed batch/stream data (Bronze layer)         | 3 (Ingestion), 4 (Transformation)  |
| herbalife_silver_container_name         | Cleaned/conformed data (Silver layer)              | 4 (Transformation)                 |

---
```

These outputs are generated after a successful Terraform deployment and can be referenced for connecting services, automation, or documentation.

---

> This phased plan is designed for learning, experimentation, and safe iteration in a development or training environment. Adjust steps as needed for your specific use case or organizational requirements.

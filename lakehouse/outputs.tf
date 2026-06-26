output "herbalife_storage_account_name" {
  description = "Name of the Herbalife storage account"
  value       = azurerm_storage_account.HL_herbalife_dev.name
}

output "herbalife_storage_account_id" {
  description = "ID of the Herbalife storage account"
  value       = azurerm_storage_account.HL_herbalife_dev.id
}

output "herbalife_log_analytics_workspace_name" {
  description = "Name of the Herbalife Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.HL_herbalife_dev.name
}

output "herbalife_log_analytics_workspace_id" {
  description = "ID of the Herbalife Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.HL_herbalife_dev.id
}

output "herbalife_eventhub_namespace_name" {
  description = "Name of the Herbalife Event Hub namespace"
  value       = azurerm_eventhub_namespace.herbalife_ns.name
}

output "herbalife_eventhub_name" {
  description = "Name of the JetOps maintenance Event Hub"
  value       = azurerm_eventhub.herbalife_hub.name
}

output "herbalife_eventhub_namespace_id" {
  description = "ID of the Herbalife Event Hub namespace"
  value       = azurerm_eventhub_namespace.herbalife_ns.id
}

output "herbalife_raw_capture_path" {
  description = "Blob prefix where JetOps maintenance capture files land in the raw container"
  value       = "raw/jetops-maintenance/${azurerm_eventhub_namespace.herbalife_ns.name}/${azurerm_eventhub.herbalife_hub.name}"
}

output "herbalife_databricks_workspace_name" {
  description = "Name of the Herbalife Databricks workspace"
  value       = azurerm_databricks_workspace.HL_herbalife_dev.name
}

output "herbalife_databricks_workspace_id" {
  description = "ID of the Herbalife Databricks workspace"
  value       = azurerm_databricks_workspace.HL_herbalife_dev.id
}

output "herbalife_search_service_name" {
  description = "Name of the Azure AI Search service used for maintenance-history RAG"
  value       = azurerm_search_service.HL_herbalife_dev.name
}

output "herbalife_search_service_endpoint" {
  description = "Query endpoint for the Azure AI Search service"
  value       = "https://${azurerm_search_service.HL_herbalife_dev.name}.search.windows.net"
}

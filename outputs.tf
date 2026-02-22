# Herbalife Lakehouse Outputs
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

output "herbalife_eventhub_namespace_id" {
  description = "ID of the Herbalife Event Hub namespace"
  value       = azurerm_eventhub_namespace.herbalife_ns.id
}

output "herbalife_databricks_workspace_name" {
  description = "Name of the Herbalife Databricks workspace"
  value       = azurerm_databricks_workspace.HL_herbalife_dev.name
}

output "herbalife_databricks_workspace_id" {
  description = "ID of the Herbalife Databricks workspace"
  value       = azurerm_databricks_workspace.HL_herbalife_dev.id
}
# Rycrawl Test Server Public IP
output "rycrawl_test_server_public_ip" {
  description = "Public IP address of the Rycrawl test Windows Server VM"
  value       = azurerm_public_ip.rycrawl_test_public_ip.ip_address
}
output "resource_group_name" {
  description = "The name of the deployed resource group"
  value       = azurerm_resource_group.aviator.name
}

output "aks_cluster_name" {
  description = "The name of the Aviator Core AKS cluster"
  value       = azurerm_kubernetes_cluster.aviator_core.name
}

output "aks_control_plane_fqdn" {
  description = "The FQDN of the AKS control plane for API access"
  value       = azurerm_kubernetes_cluster.aviator_core.fqdn
}

output "hub_vnet_id" {
  description = "The ID of the Hub VNet for future peering"
  value       = azurerm_virtual_network.hub.id
}
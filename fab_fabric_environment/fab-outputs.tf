# fab-outputs.tf
# Outputs for Microsoft Fabric environment

output "fabric_workspace_id" {
  description = "ID of the Fabric workspace (to be created)"
  value       = "<to-be-populated>"
}

output "fab_storage_account_name" {
  description = "Name of the Fabric storage account"
  value       = azurerm_storage_account.fabric.name
}

output "fab_storage_account_id" {
  description = "ID of the Fabric storage account"
  value       = azurerm_storage_account.fabric.id
}

# Add more outputs as needed

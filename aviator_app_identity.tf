# Managed Identity for AKS Workload Identity
resource "azurerm_user_assigned_identity" "aviator_app_identity" {
  name                = "aviator-app-identity"
  resource_group_name = "rg-aviator-core-prod"
  location            = "eastus2"
}

# Assign AcrPull role for ACR access
resource "azurerm_role_assignment" "acr_pull" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.aviator_app_identity.principal_id
}

# Assign Reader role for Azure SQL (update scope as needed)
resource "azurerm_role_assignment" "sql_reader" {
  scope                = azurerm_mssql_server.aviator_sql.id
  role_definition_name = "Reader"
  principal_id         = azurerm_user_assigned_identity.aviator_app_identity.principal_id
}

# Output identity details for use in Kubernetes YAML
output "aviator_app_identity_client_id" {
  value = azurerm_user_assigned_identity.aviator_app_identity.client_id
}
output "aviator_app_identity_resource_id" {
  value = azurerm_user_assigned_identity.aviator_app_identity.id
}

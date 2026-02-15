# Create the Azure Container Registry
resource "azurerm_container_registry" "acr" {
  name                = "aviatoracrjetops01"
  resource_group_name = "rg-aviator-core-prod"
  location            = "East US 2"
  sku                 = "Basic"
  admin_enabled       = true
}

# Attach ACR to AKS (The Role Assignment)
resource "azurerm_role_assignment" "aks_to_acr" {
  # Change 'aks' to 'aviator_core' to match your resource name
  principal_id                     = azurerm_kubernetes_cluster.aviator_core.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true

  lifecycle {
    ignore_changes = [
      principal_id,
      role_definition_name,
      scope,
      skip_service_principal_aad_check
    ]
  }
}
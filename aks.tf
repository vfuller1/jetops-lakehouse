# 1. Create the User-Assigned Identity
resource "azurerm_user_assigned_identity" "aviator_identity" {
  name                = "id-aviator-core-prod"
  location            = azurerm_resource_group.aviator.location
  resource_group_name = azurerm_resource_group.aviator.name
}

# 2. Configure the AKS Cluster
resource "azurerm_kubernetes_cluster" "aviator_core" {
  name                = "aks-aviator-core"
  location            = azurerm_resource_group.aviator.location
  resource_group_name = azurerm_resource_group.aviator.name
  dns_prefix          = "aviatorcore"

  # These features must be enabled for the SQL connection to work
  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  default_node_pool {
    name                        = "default"
    node_count                  = 1
    vm_size                     = "Standard_D2as_v6"
    os_disk_type                = "Managed"
    vnet_subnet_id              = azurerm_subnet.aks_subnet.id
    temporary_name_for_rotation = "temppool"
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aviator_identity.id]
  }

  depends_on = [azurerm_role_assignment.aks_network_contributor]

  tags = {
    Environment = "Production"
    Project     = "Aviator Core"
  }
}
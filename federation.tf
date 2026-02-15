resource "azurerm_federated_identity_credential" "aviator_federated_credential" {
  name                = "fic-aviator-core-v2"
  resource_group_name = azurerm_user_assigned_identity.aviator_identity.resource_group_name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = "https://eastus2.oic.prod-aks.azure.com/3246f21f-4c75-481d-8284-80c8ce2b36d1/8c35f38b-7102-4418-aaef-1095d44166cb/"
  parent_id           = azurerm_user_assigned_identity.aviator_identity.id
  subject             = "system:serviceaccount:default:aviator-service-account"
  depends_on          = [azurerm_user_assigned_identity.aviator_identity]
}

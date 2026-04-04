resource "azurerm_eventhub_namespace" "herbalife_ns" {
  name                = "herbalife-clickstream-ns-prod"
  location            = "eastus2"
  resource_group_name = "rg-herbalife-terraform-state-prod"
  sku                 = "Standard"
  capacity            = 1
}

resource "azurerm_eventhub" "herbalife_hub" {
  name              = "herbalife-clickstream-hub-prod"
  namespace_id      = azurerm_eventhub_namespace.herbalife_ns.id
  partition_count   = 2
  message_retention = 1
}

resource "azurerm_eventhub_authorization_rule" "herbalife_send" {
  name                = "send"
  namespace_name      = azurerm_eventhub_namespace.herbalife_ns.name
  eventhub_name       = azurerm_eventhub.herbalife_hub.name
  resource_group_name = azurerm_eventhub_namespace.herbalife_ns.resource_group_name
  send                = true
}

output "herbalife_eventhub_send_connection_string" {
  value     = azurerm_eventhub_authorization_rule.herbalife_send.primary_connection_string
  sensitive = true
}

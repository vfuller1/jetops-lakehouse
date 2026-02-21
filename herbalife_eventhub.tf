resource "azurerm_eventhub_namespace" "HL_herbalife_dev" {
  name                = "eh-herbalife-dev"
  location            = azurerm_resource_group.HL_herbalife_dev_core.location
  resource_group_name = azurerm_resource_group.HL_herbalife_dev_core.name
  sku                 = "Standard"
  tags                = local.herbalife_common_tags
}

resource "azurerm_eventhub" "HL_herbalife_dev" {
  name                = "eventhub-herbalife-dev"
  namespace_name      = azurerm_eventhub_namespace.HL_herbalife_dev.name
  resource_group_name = azurerm_resource_group.HL_herbalife_dev_core.name
  partition_count     = 2
  message_retention   = 1
}

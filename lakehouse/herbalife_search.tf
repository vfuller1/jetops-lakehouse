resource "azurerm_search_service" "HL_herbalife_dev" {
  name                = var.herbalife_search_service_name
  resource_group_name = azurerm_resource_group.HL_herbalife_dev_core.name
  location            = var.herbalife_search_region
  sku                 = "basic"
  tags                = local.herbalife_common_tags
}

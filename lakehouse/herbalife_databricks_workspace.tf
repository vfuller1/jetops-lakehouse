resource "azurerm_databricks_workspace" "HL_herbalife_dev" {
  name                = var.herbalife_databricks_workspace_name
  resource_group_name = azurerm_resource_group.HL_herbalife_dev_core.name
  location            = azurerm_resource_group.HL_herbalife_dev_core.location
  sku                 = "standard"
  tags                = local.herbalife_common_tags
}

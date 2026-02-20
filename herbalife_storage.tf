resource "azurerm_storage_account" "HL_herbalife_dev" {
  name                     = var.herbalife_storage_account_name
  resource_group_name      = azurerm_resource_group.HL_herbalife_dev_core.name
  location                 = azurerm_resource_group.HL_herbalife_dev_core.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = local.herbalife_common_tags
}

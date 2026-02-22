resource "azurerm_storage_account" "HL_herbalife_dev" {
  name                     = var.herbalife_storage_account_name
  resource_group_name      = azurerm_resource_group.HL_herbalife_dev_core.name
  location                 = azurerm_resource_group.HL_herbalife_dev_core.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = true
  tags                     = local.herbalife_common_tags
}

# Lakehouse containers
resource "azurerm_storage_container" "raw" {
  name                  = "raw"
  storage_account_name  = azurerm_storage_account.HL_herbalife_dev.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "bronze" {
  name                  = "bronze"
  storage_account_name  = azurerm_storage_account.HL_herbalife_dev.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "silver" {
  name                  = "silver"
  storage_account_name  = azurerm_storage_account.HL_herbalife_dev.name
  container_access_type = "private"
}

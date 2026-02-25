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

resource "azurerm_storage_container" "gold" {
  name                  = "gold"
  storage_account_name  = azurerm_storage_account.HL_herbalife_dev.name
  container_access_type = "private"
}

# Assign Storage Blob Data Contributor role to user
resource "azurerm_role_assignment" "blob_data_contributor" {
  scope                = azurerm_storage_account.HL_herbalife_dev.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = "7fd6cca4-0001-4c96-ad5d-781f8a336d56"
}

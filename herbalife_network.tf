# Herbalife Lakehouse Phase 1 Network Resources
# All resources are new and use the 'HL' prefix to avoid conflicts with JetOps.

resource "azurerm_resource_group" "HL_herbalife_dev_core" {
  name     = var.herbalife_resource_group_name
  location = var.herbalife_region
  tags     = local.herbalife_common_tags
}

resource "azurerm_virtual_network" "HL_herbalife_dev_hub" {
  name                = "vnet-herbalife-dev-hub"
  location            = azurerm_resource_group.HL_herbalife_dev_core.location
  resource_group_name = azurerm_resource_group.HL_herbalife_dev_core.name
  address_space       = ["10.20.0.0/16"]
  tags                = local.herbalife_common_tags
}

resource "azurerm_virtual_network" "HL_herbalife_dev_spoke" {
  name                = "vnet-herbalife-dev-spoke"
  location            = azurerm_resource_group.HL_herbalife_dev_core.location
  resource_group_name = azurerm_resource_group.HL_herbalife_dev_core.name
  address_space       = ["10.21.0.0/16"]
  tags                = local.herbalife_common_tags
}

resource "azurerm_subnet" "HL_herbalife_dev_data" {
  name                 = "subnet-data-herbalife-dev"
  resource_group_name  = azurerm_resource_group.HL_herbalife_dev_core.name
  virtual_network_name = azurerm_virtual_network.HL_herbalife_dev_spoke.name
  address_prefixes     = ["10.21.1.0/24"]
}

resource "azurerm_network_security_group" "HL_herbalife_dev_data" {
  name                = "nsg-data-herbalife-dev"
  location            = azurerm_resource_group.HL_herbalife_dev_core.location
  resource_group_name = azurerm_resource_group.HL_herbalife_dev_core.name
}

resource "azurerm_subnet_network_security_group_association" "HL_herbalife_dev_data_assoc" {
  subnet_id                 = azurerm_subnet.HL_herbalife_dev_data.id
  network_security_group_id = azurerm_network_security_group.HL_herbalife_dev_data.id
}

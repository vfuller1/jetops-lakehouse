# NSG for Rycrawl Test Subnet
resource "azurerm_network_security_group" "rycrawl_test_nsg" {
  name                = "nsg-rycrawl-test"
  location            = azurerm_resource_group.aviator.location
  resource_group_name = azurerm_resource_group.aviator.name
}

# Allow RDP from your laptop (replace with your public IP)
resource "azurerm_network_security_rule" "rycrawl_test_rdp" {
  name                        = "allow-rdp-from-laptop"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "67.167.204.211/32"
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.rycrawl_test_nsg.name
  resource_group_name         = azurerm_resource_group.aviator.name
}

# Associate NSG with the Rycrawl test subnet
resource "azurerm_subnet_network_security_group_association" "rycrawl_test_subnet_assoc" {
  subnet_id                 = azurerm_subnet.rycrawl_test_subnet.id
  network_security_group_id = azurerm_network_security_group.rycrawl_test_nsg.id
}
# networking.tf

# Resource Group
resource "azurerm_resource_group" "aviator" {
  name     = var.resource_group_name
  location = var.location
}

# Hub VNet (Networking & Edge Security)
resource "azurerm_virtual_network" "hub" {
  name                = "vnet-hub-aviator"
  location            = azurerm_resource_group.aviator.location
  resource_group_name = azurerm_resource_group.aviator.name
  address_space       = ["10.0.0.0/16"]
}

# Spoke VNet (Aviator Core Workloads)
resource "azurerm_virtual_network" "spoke" {
  name                = "vnet-spoke-aviator"
  location            = azurerm_resource_group.aviator.location
  resource_group_name = azurerm_resource_group.aviator.name
  address_space       = ["10.1.0.0/16"]
}

# Dedicated Subnet for SQL Managed Instance (Delegated)
resource "azurerm_subnet" "sql_subnet" {
  name                 = "snet-sql-aviator"
  resource_group_name  = azurerm_resource_group.aviator.name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = ["10.1.2.0/24"]

  delegation {
    name = "managedinstancedelegation"
    service_delegation {
      name    = "Microsoft.Sql/managedInstances"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action", 
        "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action"
      ]
    }
  }
}

# New Subnet for Private Endpoints (No delegation!)
resource "azurerm_subnet" "endpoint_subnet" {
  name                 = "snet-endpoints-aviator"
  resource_group_name  = azurerm_resource_group.aviator.name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = ["10.1.3.0/24"]
}

# Dedicated Subnet for Rycrawl Test Server (No delegation)
resource "azurerm_subnet" "rycrawl_test_subnet" {
  name                 = "snet-rycrawl-test"
  resource_group_name  = azurerm_resource_group.aviator.name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = ["10.1.4.0/24"]
}

# Private DNS Zone for SQL Name Resolution
resource "azurerm_private_dns_zone" "sql_dns" {
  name                = "privatelink.database.windows.net"
  resource_group_name = azurerm_resource_group.aviator.name
}

# Link DNS Zone to the Spoke VNet
resource "azurerm_private_dns_zone_virtual_network_link" "sql_dns_link" {
  name                  = "sql-dns-link"
  resource_group_name   = azurerm_resource_group.aviator.name
  private_dns_zone_name = azurerm_private_dns_zone.sql_dns.name
  virtual_network_id    = azurerm_virtual_network.spoke.id
}

# VNet Peering
resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  name                      = "hub-to-spoke"
  resource_group_name       = azurerm_resource_group.aviator.name
  virtual_network_name      = azurerm_virtual_network.hub.name
  remote_virtual_network_id = azurerm_virtual_network.spoke.id
}
# Network Security Group for SQL Private Endpoint Subnet
resource "azurerm_network_security_group" "sql_endpoint_nsg" {
  name                = "nsg-sql-endpoint-aviator"
  location            = azurerm_resource_group.aviator.location
  resource_group_name = azurerm_resource_group.aviator.name
}

# Allow SQL traffic from AKS subnet (assuming AKS nodes are in 10.1.0.0/16)
resource "azurerm_network_security_rule" "allow_sql_from_aks" {
  name                        = "allow-sql-from-aks"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "1433"
  source_address_prefix       = "10.1.0.0/16"
  destination_address_prefix  = "10.1.3.0/24"
  network_security_group_name = azurerm_network_security_group.sql_endpoint_nsg.name
  resource_group_name         = azurerm_resource_group.aviator.name
}

# Associate NSG with the endpoint subnet
resource "azurerm_subnet_network_security_group_association" "endpoint_subnet_assoc" {
  subnet_id                 = azurerm_subnet.endpoint_subnet.id
  network_security_group_id = azurerm_network_security_group.sql_endpoint_nsg.id
}

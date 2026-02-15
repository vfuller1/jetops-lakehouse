# Azure SQL Logical Server
resource "azurerm_mssql_server" "aviator_sql" {
  name                         = "sql-server-aviator-jetops01"
  resource_group_name          = azurerm_resource_group.aviator.name
  location                     = azurerm_resource_group.aviator.location
  version                      = "12.0"
  administrator_login          = "aviatoradmin"
  administrator_login_password = var.sql_admin_password
  public_network_access_enabled = false 

  # ADDED: This enables Microsoft Entra authentication for the server
  azuread_administrator {
    login_username = "vfuller100_outlook.com#EXT#@vfuller100outlook.onmicrosoft.com"
    object_id      = "5ef08eb8-8ed2-49b3-8eb2-46fba1215518"
    tenant_id      = var.tenant_id
  }
}

# Azure SQL Database
resource "azurerm_mssql_database" "maintenance_db" {
  name      = "db-airplane-maintenance"
  server_id = azurerm_mssql_server.aviator_sql.id
  sku_name  = "S0"
}

# Private Endpoint for Secure DB Access
resource "azurerm_private_endpoint" "sql_endpoint" {
  name                = "pe-aviator-sql"
  location            = azurerm_resource_group.aviator.location
  resource_group_name = azurerm_resource_group.aviator.name
  subnet_id           = azurerm_subnet.endpoint_subnet.id 

  private_service_connection {
    name                           = "sql-privatelink"
    private_connection_resource_id = azurerm_mssql_server.aviator_sql.id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "sql-dns-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.sql_dns.id]
  }
}
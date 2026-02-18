# Private Endpoint for Azure SQL Server
resource "azurerm_private_endpoint" "sql_private_endpoint" {
  name                = "pe-sql-aviator"
  location            = azurerm_resource_group.aviator.location
  resource_group_name = azurerm_resource_group.aviator.name
  subnet_id           = azurerm_subnet.endpoint_subnet.id

  private_service_connection {
    name                           = "sqlserver-privateserviceconnection"
    private_connection_resource_id = azurerm_mssql_server.aviator_sql.id
    is_manual_connection           = false
    subresource_names              = ["sqlServer"]
  }

  private_dns_zone_group {
    name                 = "sql-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.sql_dns.id]
  }
}

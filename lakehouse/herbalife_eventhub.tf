resource "azurerm_eventhub_namespace" "herbalife_ns" {
  name                = var.herbalife_eventhub_namespace_name
  location            = "eastus2"
  resource_group_name = azurerm_resource_group.HL_herbalife_dev_core.name
  sku                 = "Standard"
  capacity            = 1
}

resource "azurerm_eventhub" "herbalife_hub" {
  name              = var.herbalife_eventhub_name
  namespace_id      = azurerm_eventhub_namespace.herbalife_ns.id
  partition_count   = 2
  message_retention = 1

  capture_description {
    enabled             = true
    encoding            = "Avro"
    interval_in_seconds = 300
    size_limit_in_bytes = 10485760
    skip_empty_archives = true

    destination {
      name                 = "EventHubArchive.AzureBlockBlob"
      archive_name_format  = "jetops-maintenance/{Namespace}/{EventHub}/{PartitionId}/{Year}/{Month}/{Day}/{Hour}/{Minute}/{Second}"
      blob_container_name  = azurerm_storage_container.raw.name
      storage_account_id   = azurerm_storage_account.HL_herbalife_dev.id
    }
  }
}

resource "azurerm_eventhub_authorization_rule" "herbalife_send" {
  name                = "send"
  namespace_name      = azurerm_eventhub_namespace.herbalife_ns.name
  eventhub_name       = azurerm_eventhub.herbalife_hub.name
  resource_group_name = azurerm_eventhub_namespace.herbalife_ns.resource_group_name
  send                = true
}

output "herbalife_eventhub_send_connection_string" {
  value     = azurerm_eventhub_authorization_rule.herbalife_send.primary_connection_string
  sensitive = true
}

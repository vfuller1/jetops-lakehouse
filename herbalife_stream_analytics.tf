resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

resource "azurerm_storage_account" "function_storage" {
  name                     = "funcstor${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.HL_herbalife_dev_core.name
  location                 = azurerm_resource_group.HL_herbalife_dev_core.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "function_plan" {
  name                = "herbalife-func-plan"
  location            = azurerm_resource_group.HL_herbalife_dev_core.location
  resource_group_name = azurerm_resource_group.HL_herbalife_dev_core.name
  sku_name            = "Y1"
  os_type             = "Linux"
  # sku_tier removed; not valid for azurerm_service_plan
}

resource "azurerm_function_app" "eventhub_func" {
  name                       = "herbalife-eventhub-func"
  location                   = azurerm_resource_group.HL_herbalife_dev_core.location
  resource_group_name        = azurerm_resource_group.HL_herbalife_dev_core.name
  app_service_plan_id        = azurerm_service_plan.function_plan.id
  storage_account_name       = azurerm_storage_account.function_storage.name
  storage_account_access_key = azurerm_storage_account.function_storage.primary_access_key
  version                    = "~4"
  os_type                    = "linux"

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME      = "python"
    EVENTHUB_CONNECTION_STRING    = azurerm_eventhub_authorization_rule.herbalife_send.primary_connection_string
    EVENTHUB_NAME                 = azurerm_eventhub.herbalife_hub.name
    AzureWebJobsStorage           = azurerm_storage_account.function_storage.primary_connection_string
  }
}

output "function_app_name" {
  value = azurerm_function_app.eventhub_func.name
}

output "function_app_id" {
  value = azurerm_function_app.eventhub_func.id
}
resource "azurerm_stream_analytics_job" "herbalife_stream_job" {
  name                = "herbalife-stream-job"
  location            = azurerm_resource_group.HL_herbalife_dev_core.location
  resource_group_name = azurerm_resource_group.HL_herbalife_dev_core.name
  streaming_units     = 1
  compatibility_level = "1.2"
  data_locale         = "en-US"
  output_error_policy = "Stop"
  transformation_query = <<QUERY
    SELECT * INTO [DataLakeOutput] FROM [EventHubInput]
  QUERY
}

output "herbalife_stream_job_name" {
  value = azurerm_stream_analytics_job.herbalife_stream_job.name
}

output "herbalife_stream_job_id" {
  value = azurerm_stream_analytics_job.herbalife_stream_job.id
}

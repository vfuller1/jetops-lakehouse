resource "azurerm_stream_analytics_stream_input_eventhub" "herbalife_eventhub_input" {
  name                         = "EventHubInput"
  stream_analytics_job_name    = azurerm_stream_analytics_job.herbalife_stream_job.name
  resource_group_name          = azurerm_resource_group.HL_herbalife_prod_core.name
    servicebus_namespace         = azurerm_eventhub_namespace.herbalife_ns.name
  eventhub_name                = azurerm_eventhub.herbalife_hub.name
  shared_access_policy_name    = azurerm_eventhub_authorization_rule.herbalife_send.name
  shared_access_policy_key     = azurerm_eventhub_authorization_rule.herbalife_send.primary_key
  serialization {
    type     = "Json"
    encoding = "UTF8"
  }
}

resource "azurerm_stream_analytics_output_blob" "herbalife_raw_output" {
  name                = "DataLakeOutput"
  stream_analytics_job_name = azurerm_stream_analytics_job.herbalife_stream_job.name
  resource_group_name = azurerm_resource_group.HL_herbalife_prod_core.name
  storage_account_name     = azurerm_storage_account.HL_herbalife_dev.name
  storage_account_key      = azurerm_storage_account.HL_herbalife_dev.primary_access_key
  storage_container_name   = azurerm_storage_container.raw.name
  path_pattern             = "{date}/{time}"
  time_format              = "HH"
  date_format              = "yyyy/MM/dd"
  serialization {
    type     = "Json"
    encoding = "UTF8"
    format   = "LineSeparated"
  }
}
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

resource "azurerm_linux_function_app" "eventhub_func" {
  name                       = "herbalife-eventhub-func"
  location                   = azurerm_resource_group.HL_herbalife_dev_core.location
  resource_group_name        = azurerm_resource_group.HL_herbalife_dev_core.name
  service_plan_id            = azurerm_service_plan.function_plan.id
  storage_account_name       = azurerm_storage_account.function_storage.name
  storage_account_access_key = azurerm_storage_account.function_storage.primary_access_key

  site_config {
    application_stack {
      python_version = "3.11"
    }
  }

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME      = "python"
    EVENTHUB_CONNECTION_STRING    = azurerm_eventhub_authorization_rule.herbalife_send.primary_connection_string
    EVENTHUB_NAME                 = azurerm_eventhub.herbalife_hub.name
    AzureWebJobsStorage           = azurerm_storage_account.function_storage.primary_connection_string
  }
}

output "function_app_name" {
  value = azurerm_linux_function_app.eventhub_func.name
}

output "function_app_id" {
  value = azurerm_linux_function_app.eventhub_func.id
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

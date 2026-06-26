resource "azurerm_log_analytics_workspace" "HL_herbalife_dev" {
  name                = "law-herbalife-dev"
  location            = azurerm_resource_group.HL_herbalife_dev_core.location
  resource_group_name = azurerm_resource_group.HL_herbalife_dev_core.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = local.herbalife_common_tags
}

resource "azurerm_monitor_diagnostic_setting" "HL_herbalife_dev" {
  name                       = "diag-herbalife-dev"
  target_resource_id         = azurerm_storage_account.HL_herbalife_dev.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.HL_herbalife_dev.id

  enabled_metric {
    category = "AllMetrics"
  }
}

resource "azurerm_application_insights" "HL_herbalife_dev" {
  name                = "appi-herbalife-dev"
  location            = azurerm_resource_group.HL_herbalife_dev_core.location
  resource_group_name = azurerm_resource_group.HL_herbalife_dev_core.name
  workspace_id        = azurerm_log_analytics_workspace.HL_herbalife_dev.id
  application_type    = "web"
  tags                = local.herbalife_common_tags
}

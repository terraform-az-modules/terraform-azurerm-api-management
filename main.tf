##-----------------------------------------------------------------------------
## Resources
##-----------------------------------------------------------------------------
module "labels" {
  source          = "terraform-az-modules/tags/azurerm"
  version         = "1.0.2"
  name            = var.custom_name == null ? var.name : var.custom_name
  location        = var.location
  environment     = var.environment
  managedby       = var.managedby
  label_order     = var.label_order
  repository      = var.repository
  deployment_mode = var.deployment_mode
  extra_tags      = var.extra_tags
}

resource "azurerm_api_management" "main" {
  count                      = var.enable ? 1 : 0
  name                       = var.resource_position_prefix ? format("apim-%s", local.name) : format("%s-apim", local.name)
  location                   = var.location
  resource_group_name        = var.resource_group_name
  publisher_name             = var.publisher_name
  publisher_email            = var.publisher_email
  sku_name                   = var.sku_name
  client_certificate_enabled = var.client_certificate_enabled
  gateway_disabled           = var.gateway_disabled
  min_api_version            = var.min_api_version
  public_ip_address_id       = var.public_ip_address_id
  zones                      = var.zones
  virtual_network_type       = var.subnet_id == null ? null : var.virtual_network_type
  tags                       = module.labels.tags

  dynamic "virtual_network_configuration" {
    for_each = var.subnet_id == null ? [] : [var.subnet_id]
    content {
      subnet_id = virtual_network_configuration.value
    }
  }
}

resource "azurerm_api_management_logger" "main" {
  count               = var.enable && var.enable_logger ? 1 : 0
  name                = var.logger_name != null ? var.logger_name : format("%s-apim-logger", local.name)
  api_management_name = azurerm_api_management.main[0].name
  resource_group_name = var.resource_group_name
  resource_id         = local.app_insights_id

  application_insights {
    instrumentation_key = local.app_insights_instrumentation_key
  }
}

resource "azurerm_monitor_diagnostic_setting" "main" {
  count = var.enable && var.enable_diagnostic ? 1 : 0

  name = var.resource_position_prefix ? format("diag-%s", local.name) : format("%s-diag", local.name)

  target_resource_id         = azurerm_api_management.main[0].id
  log_analytics_workspace_id = var.log_analytics_workspace_id
  storage_account_id         = var.storage_account_id

  dynamic "enabled_log" {
    for_each = var.log_enabled ? ["allLogs"] : []
    content {
      category_group = enabled_log.value
    }
  }

  dynamic "enabled_metric" {
    for_each = var.metric_enabled ? ["AllMetrics"] : []
    content {
      category = enabled_metric.value
    }
  }
}

resource "azurerm_api_management_policy" "main" {
  count             = var.enable && var.policy_xml != null ? 1 : 0
  api_management_id = azurerm_api_management.main[0].id
  xml_content       = var.policy_xml
}

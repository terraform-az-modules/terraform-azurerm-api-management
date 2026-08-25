##-----------------------------------------------------------------------------
## Outputs
##-----------------------------------------------------------------------------
output "api_management_id" {
  value       = try(azurerm_api_management.main[0].id, null)
  description = "The ID of the API Management service."
}

output "api_management_name" {
  value       = try(azurerm_api_management.main[0].name, null)
  description = "The name of the API Management service."
}

output "api_management_gateway_url" {
  value       = try(azurerm_api_management.main[0].gateway_url, null)
  description = "The gateway URL for the API Management service."
}

output "api_management_logger_id" {
  value       = try(azurerm_api_management_logger.main[0].id, null)
  description = "The ID of the API Management logger."
}

output "api_management_diagnostic_setting_id" {
  value       = try(azurerm_monitor_diagnostic_setting.main[0].id, null)
  description = "The ID of the API Management diagnostic setting."
}

output "api_management_policy_id" {
  value       = try(azurerm_api_management_policy.main[0].id, null)
  description = "The ID of the API Management policy."
}

output "label_order" {
  value       = local.label_order
  description = "Label order."
}

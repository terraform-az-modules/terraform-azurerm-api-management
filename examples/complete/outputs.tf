##-----------------------------------------------------------------------------
## Outputs
##-----------------------------------------------------------------------------
output "api_management_id" {
  value = module.api_management.api_management_id
}

output "api_management_name" {
  value = module.api_management.api_management_name
}

output "api_management_gateway_url" {
  value = module.api_management.api_management_gateway_url
}

output "api_management_logger_id" {
  value = module.api_management.api_management_logger_id
}

output "api_management_diagnostic_setting_id" {
  value = module.api_management.api_management_diagnostic_setting_id
}

output "api_management_policy_id" {
  value = module.api_management.api_management_policy_id
}

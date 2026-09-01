##-----------------------------------------------------------------------------
## API Management - Core Outputs
##-----------------------------------------------------------------------------
output "id" {
  value       = try(azurerm_api_management.main[0].id, null)
  description = "The ID of the API Management Service."
}

output "name" {
  value       = try(azurerm_api_management.main[0].name, null)
  description = "The name of the API Management Service."
}

output "gateway_url" {
  value       = try(azurerm_api_management.main[0].gateway_url, null)
  description = "The URL of the Gateway for the API Management Service."
}

output "gateway_regional_url" {
  value       = try(azurerm_api_management.main[0].gateway_regional_url, null)
  description = "The Region URL for the Gateway of the API Management Service."
}

output "management_api_url" {
  value       = try(azurerm_api_management.main[0].management_api_url, null)
  description = "The URL for the Management API associated with this API Management service."
}

output "portal_url" {
  value       = try(azurerm_api_management.main[0].portal_url, null)
  description = "The URL for the Publisher Portal associated with this API Management service."
}

output "developer_portal_url" {
  value       = try(azurerm_api_management.main[0].developer_portal_url, null)
  description = "The URL for the Developer Portal associated with this API Management service."
}

output "scm_url" {
  value       = try(azurerm_api_management.main[0].scm_url, null)
  description = "The URL for the SCM (Source Code Management) endpoint associated with this API Management service."
}

output "public_ip_addresses" {
  value       = try(azurerm_api_management.main[0].public_ip_addresses, null)
  description = "The Public IP addresses of the API Management Service."
}

output "private_ip_addresses" {
  value       = try(azurerm_api_management.main[0].private_ip_addresses, null)
  description = "The Private IP addresses of the API Management Service (only when using Virtual Network mode)."
}

output "identity" {
  value = try({
    principal_id = azurerm_api_management.main[0].identity[0].principal_id
    tenant_id    = azurerm_api_management.main[0].identity[0].tenant_id
  }, null)
  description = "The principal_id and tenant_id of the API Management Service's Managed Service Identity."
}

output "hostname_configuration_proxy" {
  value       = try(azurerm_api_management.main[0].hostname_configuration[0].proxy, null)
  description = "The proxy hostname configuration block, including certificate_source and certificate_status."
}

output "tenant_access" {
  value = try({
    tenant_id     = azurerm_api_management.main[0].tenant_access[0].tenant_id
    primary_key   = azurerm_api_management.main[0].tenant_access[0].primary_key
    secondary_key = azurerm_api_management.main[0].tenant_access[0].secondary_key
  }, null)
  description = "Tenant access information contract (tenant_id, primary_key, secondary_key)."
  sensitive   = true
}

output "additional_location" {
  value       = try(azurerm_api_management.main[0].additional_location, null)
  description = "Additional location blocks, including gateway_regional_url, public_ip_addresses, and private_ip_addresses per region."
}

##-----------------------------------------------------------------------------
## Related Resource Outputs
##-----------------------------------------------------------------------------
output "public_ip_id" {
  value       = try(azurerm_public_ip.main[0].id, null)
  description = "The ID of the custom public IP created for API Management, if any."
}

output "application_insights_id" {
  value       = local.app_insights_id
  description = "The Application Insights resource ID used by this module (created or externally supplied)."
}

output "application_insights_instrumentation_key" {
  value       = local.app_insights_instrumentation_key
  description = "The Application Insights instrumentation key used by this module."
  sensitive   = true
}

output "logger_id" {
  value       = try(azurerm_api_management_logger.main[0].id, null)
  description = "The ID of the API Management logger, if created."
}

output "private_dns_zone_id" {
  value       = try(azurerm_private_dns_zone.main[0].id, null)
  description = "The ID of the private DNS zone created for the APIM private endpoint, if enabled."
}
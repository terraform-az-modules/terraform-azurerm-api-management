## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| custom_name | Override the default module name. | `string` | `null` | no |
| resource_position_prefix | Controls whether the resource type prefix is added before or after the name. | `bool` | `true` | no |
| label_order | Label order, e.g. `name`,`application`,`centralus`. | `list(any)` | `["name","environment","location"]` | no |
| name | Name used by the labels module and for Azure resource naming. | `string` | `null` | yes |
| location | Azure region where the API Management service is deployed. | `string` | `null` | no |
| environment | Environment label such as dev, qa, or prod. | `string` | `null` | no |
| managedby | ManagedBy tag value. | `string` | `"terraform-az-modules"` | no |
| repository | Terraform module repository URL. | `string` | `https://github.com/terraform-az-modules/terraform-azurerm-api-management` | no |
| deployment_mode | Specifies how the infrastructure is deployed. | `string` | `terraform` | no |
| extra_tags | Additional tags to merge into the default tag set. | `map(string)` | `null` | no |
| enable | Set to false to skip creating all resources. | `bool` | `true` | no |
| resource_group_name | Resource group that contains the API Management service. | `string` | n/a | yes |
| publisher_name | Publisher or company name for the API Management service. | `string` | n/a | yes |
| publisher_email | Publisher or company email for the API Management service. | `string` | n/a | yes |
| sku_name | API Management SKU name. | `string` | `Developer_1` | no |
| client_certificate_enabled | Whether client certificates are required at the gateway. | `bool` | `false` | no |
| gateway_disabled | Disable the gateway in the main region. | `bool` | `false` | no |
| min_api_version | The minimum API version allowed for control plane requests. | `string` | `null` | no |
| zones | Availability zones where the API Management service should be deployed. | `list(string)` | `null` | no |
| public_ip_address_id | Optional public IP address ID for the service. | `string` | `null` | no |
| virtual_network_type | Virtual network mode. Use None, Internal, or External. | `string` | `None` | no |
| subnet_id | Subnet ID for virtual network integration. | `string` | `null` | no |
| enable_logger | Create an API Management logger backed by Application Insights. | `bool` | `false` | no |
| application_insights_id | Application Insights resource ID used by the logger. | `string` | `null` | no |
| application_insights_instrumentation_key | Application Insights instrumentation key used by the logger. | `string` | `null` | no |
| logger_name | Optional custom logger name. | `string` | `null` | no |
| enable_diagnostic | Enable diagnostic settings for API Management. | `bool` | `false` | no |
| log_analytics_workspace_id | Log Analytics workspace ID used for diagnostics. | `string` | `null` | no |
| storage_account_id | Storage account ID used for diagnostics. | `string` | `null` | no |
| log_enabled | Enable diagnostic log categories. | `bool` | `true` | no |
| metric_enabled | Enable diagnostic metric categories. | `bool` | `true` | no |
| policy_xml | Optional service policy XML content. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| api_management_id | The ID of the API Management service. |
| api_management_name | The name of the API Management service. |
| api_management_gateway_url | The gateway URL for the API Management service. |
| api_management_logger_id | The ID of the API Management logger. |
| api_management_diagnostic_setting_id | The ID of the API Management diagnostic setting. |
| api_management_policy_id | The ID of the API Management policy. |
| label_order | Label order. |

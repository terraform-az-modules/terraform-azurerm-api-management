<!-- BEGIN_TF_DOCS -->

# Azure API Management Complete Example

This example provisions a complete Azure API Management deployment with:

- Resource group, virtual network, and subnet
- Public IP for the gateway
- Log Analytics workspace
- Application Insights
- API Management service
- Logger, diagnostic settings, and a simple service policy

---

## Requirements

| Name      | Version   |
|-----------|-----------|
| Terraform | >= 1.6.6  |
| Azurerm   | >= 3.116.0 |

---

## Providers

| Name    | Version   |
|---------|-----------|
| azurerm | >= 3.116.0 |

---

## Modules

| Name            | Source                                  | Version |
|-----------------|-----------------------------------------|---------|
| api_management   | ../..                                   | n/a     |
| application_insights | ../../terraform-azurerm-application-insights | n/a |
| log_analytics   | ../../terraform-azurerm-log-analytics   | n/a     |
| resource_group   | terraform-az-modules/resource-group/azurerm | 1.0.3 |
| subnet           | terraform-az-modules/subnet/azurerm     | 1.0.2   |
| vnet             | terraform-az-modules/vnet/azurerm       | 1.0.4   |

---

## Resources

| Name | Type |
|------|------|
| `azurerm_public_ip.apim` | Resource |

---

## Outputs

| Name | Description |
|------|-------------|
| `api_management_diagnostic_setting_id` | ID of the diagnostic setting |
| `api_management_gateway_url` | API Management gateway URL |
| `api_management_id` | ID of the API Management service |
| `api_management_logger_id` | ID of the logger |
| `api_management_name` | API Management service name |
| `api_management_policy_id` | ID of the policy |

<!-- END_TF_DOCS -->

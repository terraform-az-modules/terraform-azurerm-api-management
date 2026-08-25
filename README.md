<!-- This file is maintained in sync with README.yaml. -->
# Terraform Azure API Management Module

Terraform module for deploying Azure API Management with optional:

- Virtual network integration
- Application Insights logger
- Diagnostic settings
- Service policy configuration

## Requirements

| Name      | Version   |
|-----------|-----------|
| Terraform | >= 1.6.6  |
| Azurerm   | >= 3.116.0 |

## Provider

| Name    | Version   |
|---------|-----------|
| azurerm | >= 3.116.0 |

## Usage

```hcl
module "api_management" {
  source              = "terraform-az-modules/api-management/azurerm"
  version             = "x.y.z"
  name                = "core"
  environment         = "dev"
  location            = "centralus"
  resource_group_name = "rg-core-dev-centralus"
  publisher_name      = "Example"
  publisher_email     = "example@contoso.com"
  sku_name            = "Developer_1"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `name` | Name used by the labels module and for Azure resource naming. | `string` | `null` | yes |
| `location` | Azure region where the API Management service is deployed. | `string` | `null` | no |
| `environment` | Environment label such as dev, qa, or prod. | `string` | `null` | no |
| `resource_group_name` | Resource group that contains the API Management service. | `string` | n/a | yes |
| `publisher_name` | Publisher or company name for the API Management service. | `string` | n/a | yes |
| `publisher_email` | Publisher or company email for the API Management service. | `string` | n/a | yes |
| `sku_name` | API Management SKU name. | `string` | `Developer_1` | no |
| `virtual_network_type` | Virtual network mode. | `string` | `None` | no |
| `subnet_id` | Subnet ID for virtual network integration. | `string` | `null` | no |
| `enable_logger` | Create an API Management logger backed by Application Insights. | `bool` | `false` | no |
| `enable_diagnostic` | Enable diagnostic settings for API Management. | `bool` | `false` | no |
| `policy_xml` | Optional service policy XML content. | `string` | `null` | no |
| `label_order` | Label order used by the tags module. | `list(any)` | `["name","environment","location"]` | no |

## Outputs

| Name | Description |
|------|-------------|
| `api_management_id` | The ID of the API Management service. |
| `api_management_name` | The name of the API Management service. |
| `api_management_gateway_url` | The gateway URL for the API Management service. |
| `api_management_logger_id` | The ID of the API Management logger. |
| `api_management_diagnostic_setting_id` | The ID of the API Management diagnostic setting. |
| `api_management_policy_id` | The ID of the API Management policy. |

## Dependencies

- [Labels module](https://github.com/terraform-az-modules/terraform-azure-tags)

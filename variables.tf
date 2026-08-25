##-----------------------------------------------------------------------------
## Variables
##-----------------------------------------------------------------------------
variable "custom_name" {
  type        = string
  default     = null
  description = "Override the default module name."
}

variable "resource_position_prefix" {
  type        = bool
  default     = true
  description = "Controls whether the resource type prefix is added before or after the name."
}

variable "label_order" {
  type        = list(any)
  default     = ["name", "environment", "location"]
  description = "Label order, e.g. `name`,`application`,`centralus`."
}

variable "name" {
  type        = string
  default     = null
  description = "Name used by the labels module and for Azure resource naming."

  validation {
    condition     = var.name != null || var.custom_name != null
    error_message = "Either `name` or `custom_name` must be provided."
  }
}

variable "location" {
  type        = string
  default     = null
  description = "Azure region where the API Management service is deployed."
}

variable "environment" {
  type        = string
  default     = null
  description = "Environment label such as dev, qa, or prod."
}

variable "managedby" {
  type        = string
  default     = "terraform-az-modules"
  description = "ManagedBy tag value."
}

variable "repository" {
  type        = string
  default     = "https://github.com/terraform-az-modules/terraform-azurerm-api-management"
  description = "Terraform module repository URL."

  validation {
    condition     = can(regex("^https://", var.repository))
    error_message = "The repository value must be a valid HTTPS URL."
  }
}

variable "deployment_mode" {
  type        = string
  default     = "terraform"
  description = "Specifies how the infrastructure is deployed."
}

variable "extra_tags" {
  type        = map(string)
  default     = null
  description = "Additional tags to merge into the default tag set."
}

variable "enable" {
  type        = bool
  default     = true
  description = "Set to false to skip creating all resources."
}

variable "resource_group_name" {
  type        = string
  description = "Resource group that contains the API Management service."
}

variable "publisher_name" {
  type        = string
  description = "Publisher or company name for the API Management service."
}

variable "publisher_email" {
  type        = string
  description = "Publisher or company email for the API Management service."
}

variable "sku_name" {
  type        = string
  default     = "Developer_1"
  description = "API Management SKU name, for example Developer_1 or Premium_1."

  validation {
    condition     = can(regex("^(Consumption|Developer|Basic|BasicV2|Standard|StandardV2|Premium|PremiumV2)_[0-9]+$", var.sku_name))
    error_message = "The sku_name must look like `Developer_1`, `Standard_1`, or another supported APIM SKU."
  }
}

variable "client_certificate_enabled" {
  type        = bool
  default     = false
  description = "Whether client certificates are required at the gateway."
}

variable "gateway_disabled" {
  type        = bool
  default     = false
  description = "Disable the gateway in the main region."
}

variable "min_api_version" {
  type        = string
  default     = null
  description = "The minimum API version allowed for control plane requests."
}

variable "zones" {
  type        = list(string)
  default     = null
  description = "Availability zones where the API Management service should be deployed."
}

variable "public_ip_address_id" {
  type        = string
  default     = null
  description = "Optional public IP address ID for the service."
}

variable "virtual_network_type" {
  type        = string
  default     = "None"
  description = "Virtual network mode. Use None, Internal, or External."

  validation {
    condition     = contains(["None", "Internal", "External"], var.virtual_network_type)
    error_message = "virtual_network_type must be one of None, Internal, or External."
  }
}

variable "subnet_id" {
  type        = string
  default     = null
  description = "Subnet ID for virtual network integration."

  validation {
    condition = (
      var.subnet_id == null && var.virtual_network_type == "None"
      ) || (
      var.subnet_id != null && contains(["Internal", "External"], var.virtual_network_type)
    )
    error_message = "When subnet_id is set, virtual_network_type must be Internal or External. When subnet_id is not set, virtual_network_type must be None."
  }
}

variable "enable_logger" {
  type        = bool
  default     = false
  description = "Create an API Management logger backed by Application Insights."

  validation {
    condition = !var.enable_logger || (
      (
        var.app_insights_id != null &&
        var.app_insights_instrumentation_key != null
        ) || (
        var.application_insights_id != null &&
        var.application_insights_instrumentation_key != null
      )
    )
    error_message = "When enable_logger is true, provide either app_insights_id/app_insights_instrumentation_key or application_insights_id/application_insights_instrumentation_key."
  }
}

variable "app_insights_id" {
  type        = string
  default     = null
  description = "Application Insights resource ID used by the logger."
}

variable "app_insights_instrumentation_key" {
  type        = string
  default     = null
  description = "Application Insights instrumentation key used by the logger."
}

variable "application_insights_id" {
  type        = string
  default     = null
  description = "Application Insights resource ID used by the logger."
}

variable "application_insights_instrumentation_key" {
  type        = string
  default     = null
  description = "Application Insights instrumentation key used by the logger."
}

variable "logger_name" {
  type        = string
  default     = null
  description = "Optional custom logger name."
}

variable "enable_diagnostic" {
  type        = bool
  default     = false
  description = "Enable diagnostic settings for API Management."

  validation {
    condition     = !var.enable_diagnostic || (var.log_analytics_workspace_id != null || var.storage_account_id != null)
    error_message = "When enable_diagnostic is true, at least one of log_analytics_workspace_id or storage_account_id must be provided."
  }
}

variable "log_analytics_workspace_id" {
  type        = string
  default     = null
  description = "Log Analytics workspace ID used for diagnostics."
}

variable "storage_account_id" {
  type        = string
  default     = null
  description = "Storage account ID used for diagnostics."
}

variable "log_enabled" {
  type        = bool
  default     = true
  description = "Enable diagnostic log categories."
}

variable "metric_enabled" {
  type        = bool
  default     = true
  description = "Enable diagnostic metric categories."
}

variable "policy_xml" {
  type        = string
  default     = null
  description = "Optional service policy XML content."
}

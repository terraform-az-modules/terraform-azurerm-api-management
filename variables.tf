##-----------------------------------------------------------------------------
## Labels / Naming
##-----------------------------------------------------------------------------
variable "custom_name" {
  type        = string
  default     = null
  description = "Override the default module name."
}

variable "name" {
  type        = string
  default     = null
  description = "Name used by the labels module and for Azure resource naming."
}

variable "resource_position_prefix" {
  type        = bool
  default     = true
  description = "Controls whether the resource type prefix is added before or after the name."
}

variable "label_order" {
  type        = list(any)
  default     = ["name", "environment", "location"]
  description = "Label order, e.g. `name`,`environment`,`location`."
}

variable "location" {
  type        = string
  default     = null
  description = "Azure region where the API Management service and related resources are deployed."
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

##-----------------------------------------------------------------------------
## General
##-----------------------------------------------------------------------------
variable "enable" {
  type        = bool
  default     = true
  description = "Set to false to prevent the module from creating any resources."
}

variable "resource_group_name" {
  type        = string
  description = "Resource group that contains the API Management service and related resources."
}

##-----------------------------------------------------------------------------
## API Management - Core
##-----------------------------------------------------------------------------
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
  description = "Enforce a client certificate on each gateway request. Only supported when sku_name is a Consumption SKU."
}

variable "gateway_disabled" {
  type        = bool
  default     = false
  description = "Disable the gateway in the main region. Only supported when additional_location is set."
}

variable "min_api_version" {
  type        = string
  default     = null
  description = "The minimum API version allowed for control plane requests."
}

variable "notification_sender_email" {
  type        = string
  default     = null
  description = "Email address from which notifications will be sent."
}

variable "zones" {
  type        = list(string)
  default     = null
  description = "Availability zones where the API Management service should be deployed. Only supported on the Premium tier."
}

variable "public_ip_address_id" {
  type        = string
  default     = null
  description = "Optional externally supplied public IP address ID for the service (ignored if enable_custom_public_ip creates one)."
}

variable "public_network_access_enabled" {
  type        = bool
  default     = true
  description = "Whether public network access is enabled for the API Management service (management plane only). Must be true on creation."
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
}

variable "additional_location" {
  description = "Configuration for additional locations in API Management."
  type = list(object({
    location             = string
    capacity             = number
    zones                = optional(list(string), [])
    public_ip_address_id = optional(string)
    gateway_disabled     = optional(bool, false)

    virtual_network_configuration = optional(object({
      subnet_id = string
    }))
  }))
  default = null
}

variable "certificate" {
  description = "Configuration for API Management certificates (up to 10)."
  type = list(object({
    encoded_certificate  = string
    store_name           = string
    certificate_password = optional(string)
  }))
  default = null
}

variable "protocols" {
  description = "Protocol settings for the API Management service."
  type = object({
    http2_enabled = optional(bool, false)
  })
  default = null
}

variable "hostname_configuration" {
  description = "Configuration for API Management hostname bindings (management, portal, developer_portal, proxy, scm)."
  type = object({
    management = optional(list(object({
      host_name                       = string
      key_vault_certificate_id        = optional(string)
      certificate                     = optional(string)
      certificate_password            = optional(string)
      negotiate_client_certificate    = optional(bool, false)
      ssl_keyvault_identity_client_id = optional(string)
    })), [])

    portal = optional(list(object({
      host_name                       = string
      key_vault_certificate_id        = optional(string)
      certificate                     = optional(string)
      certificate_password            = optional(string)
      negotiate_client_certificate    = optional(bool, false)
      ssl_keyvault_identity_client_id = optional(string)
    })), [])

    developer_portal = optional(list(object({
      host_name                       = string
      key_vault_certificate_id        = optional(string)
      certificate                     = optional(string)
      certificate_password            = optional(string)
      negotiate_client_certificate    = optional(bool, false)
      ssl_keyvault_identity_client_id = optional(string)
    })), [])

    proxy = optional(list(object({
      default_ssl_binding             = optional(bool, false)
      host_name                       = string
      key_vault_certificate_id        = optional(string)
      certificate                     = optional(string)
      certificate_password            = optional(string)
      negotiate_client_certificate    = optional(bool, false)
      ssl_keyvault_identity_client_id = optional(string)
    })), [])

    scm = optional(list(object({
      host_name                       = string
      key_vault_certificate_id        = optional(string)
      certificate                     = optional(string)
      certificate_password            = optional(string)
      negotiate_client_certificate    = optional(bool, false)
      ssl_keyvault_identity_client_id = optional(string)
    })), [])
  })
  default = null
}

variable "delegation" {
  description = "Configuration for API Management delegation settings."
  type = object({
    subscriptions_enabled     = optional(bool, false)
    user_registration_enabled = optional(bool, false)
    url                       = optional(string)
    validation_key            = optional(string)
  })
  default = null
}

variable "sign_in" {
  description = "Configuration for API Management sign-in settings."
  type = object({
    enabled = bool
  })
  default = null
}

variable "sign_up" {
  description = "Sign-up settings for API Management. terms_of_service is required by the provider whenever this block is set."
  type = object({
    enabled = bool
    terms_of_service = object({
      enabled          = bool
      consent_required = bool
      text             = optional(string)
    })
  })
  default = null
}

variable "tenant_access" {
  description = "Tenant access settings for the management API."
  type = object({
    enabled = bool
  })
  default = null
}

variable "security" {
  description = "Security settings for API Management, including TLS and cipher configurations. Field names match the azurerm provider schema (e.g. backend_ssl30_enabled, not enable_backend_ssl30)."
  type = object({
    backend_ssl30_enabled                               = optional(bool, false)
    backend_tls10_enabled                               = optional(bool, false)
    backend_tls11_enabled                               = optional(bool, false)
    frontend_ssl30_enabled                              = optional(bool, false)
    frontend_tls10_enabled                              = optional(bool, false)
    frontend_tls11_enabled                              = optional(bool, false)
    tls_ecdhe_ecdsa_with_aes128_cbc_sha_ciphers_enabled = optional(bool, false)
    tls_ecdhe_ecdsa_with_aes256_cbc_sha_ciphers_enabled = optional(bool, false)
    tls_ecdhe_rsa_with_aes128_cbc_sha_ciphers_enabled   = optional(bool, false)
    tls_ecdhe_rsa_with_aes256_cbc_sha_ciphers_enabled   = optional(bool, false)
    tls_rsa_with_aes128_cbc_sha256_ciphers_enabled      = optional(bool, false)
    tls_rsa_with_aes128_cbc_sha_ciphers_enabled         = optional(bool, false)
    tls_rsa_with_aes128_gcm_sha256_ciphers_enabled      = optional(bool, false)
    tls_rsa_with_aes256_gcm_sha384_ciphers_enabled      = optional(bool, false)
    tls_rsa_with_aes256_cbc_sha256_ciphers_enabled      = optional(bool, false)
    tls_rsa_with_aes256_cbc_sha_ciphers_enabled         = optional(bool, false)
    triple_des_ciphers_enabled                          = optional(bool, false)
  })
  default = null
}

variable "identity_type" {
  type        = string
  default     = "SystemAssigned"
  description = "Managed identity type: SystemAssigned, UserAssigned, `SystemAssigned, UserAssigned`, or null to omit the identity block."
}

variable "identity_ids" {
  type        = list(string)
  default     = null
  description = "List of user assigned identity IDs (required when identity_type includes UserAssigned)."
}

variable "timeouts" {
  description = "Optional custom timeouts for the azurerm_api_management resource."
  type = object({
    create = optional(string)
    read   = optional(string)
    update = optional(string)
    delete = optional(string)
  })
  default = null
}

variable "policy_xml" {
  type        = string
  default     = null
  description = "Optional service-level policy XML content."
}

##-----------------------------------------------------------------------------
## Public IP
##-----------------------------------------------------------------------------
variable "enable_custom_public_ip" {
  type        = bool
  default     = false
  description = "Create and attach a custom Standard public IP (only applies to Developer/Premium SKUs)."
}

##-----------------------------------------------------------------------------
## Logger / Diagnostics
##-----------------------------------------------------------------------------
variable "enable_logger" {
  type        = bool
  default     = false
  description = "Create an API Management logger backed by Application Insights."
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
  description = "Log Analytics workspace ID used for diagnostics and/or Application Insights workspace-based mode."
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

##-----------------------------------------------------------------------------
## Application Insights
##-----------------------------------------------------------------------------
variable "application_insights_enabled" {
  type        = bool
  default     = true
  description = "Enable or create Application Insights for the API Management instance."
}

variable "application_insights_id" {
  type        = string
  default     = null
  description = "The ID of an existing Application Insights resource to use. If null, a new resource will be created."
}

variable "application_insights_instrumentation_key" {
  type        = string
  default     = null
  description = "Instrumentation key of an existing Application Insights resource (required together with application_insights_id)."
}

variable "application_insights_type" {
  type        = string
  default     = "web"
  description = "The type of Application Insights resource to create (e.g., 'web', 'other')."
}

variable "application_insights_sampling_percentage" {
  type        = number
  default     = 100
  description = "The percentage of telemetry data to sample. Must be between 0 and 100."
  validation {
    condition     = var.application_insights_sampling_percentage >= 0 && var.application_insights_sampling_percentage <= 100
    error_message = "The sampling percentage must be between 0 and 100."
  }
}

variable "retention_in_days" {
  type        = number
  default     = 90
  description = "The retention period for data in days. Must be between 30 and 730."
  validation {
    condition     = var.retention_in_days >= 30 && var.retention_in_days <= 730
    error_message = "The retention period must be between 30 and 730 days."
  }
}

variable "ip_masking_enabled" {
  type        = bool
  default     = true
  description = "Enable IP masking for Application Insights."
}

##-----------------------------------------------------------------------------
## API Management - APIs
##-----------------------------------------------------------------------------
variable "enable_api_management_api" {
  type        = bool
  default     = false
  description = "Flag to enable or disable API management API deployment."
}

variable "apis" {
  description = "List of APIs for API Management."
  type = list(object({
    name                = string
    resource_group_name = string
    revision            = string
    display_name        = string
    path                = string
    protocols           = list(string)

    service_url           = optional(string)
    revision_description  = optional(string)
    api_type              = optional(string, "http")
    description           = optional(string)
    subscription_required = optional(bool, true)
    terms_of_service_url  = optional(string)
    version               = optional(string)
    version_description   = optional(string)
    version_set_id        = optional(string)

    import = optional(object({
      content_format = string
      content_value  = string
      wsdl_selector = optional(list(object({
        service_name  = string
        endpoint_name = string
      })))
    }))

    oauth2_authorization = optional(object({
      authorization_server_name = string
      scope                     = string
    }))

    openid_authentication = optional(object({
      openid_provider_name         = string
      bearer_token_sending_methods = list(string)
    }))
  }))
  default = []
}

##-----------------------------------------------------------------------------
## API Management - API Version Set
##-----------------------------------------------------------------------------
variable "enable_api_version_set" {
  type        = bool
  default     = false
  description = "Set to true to create the API version set resource."
}

variable "api_version_set_display_name" {
  type        = string
  default     = ""
  description = "The display name of the API version set."
}

variable "versioning_scheme" {
  type        = string
  default     = ""
  description = "Defines the versioning scheme for the API. Example values: 'Segment', 'Query', 'Header'."
}

variable "api_version_set_optional_fields" {
  type        = map(string)
  default     = {}
  description = "Optional fields for the API version set: description, version_header_name, version_query_name."
}

##-----------------------------------------------------------------------------
## API Management - API Policy
##-----------------------------------------------------------------------------
variable "enable_api_policy" {
  type        = bool
  default     = false
  description = "Set to true to create the API-level policy resource."
}

variable "api_name_api_policy" {
  type        = string
  default     = ""
  description = "The name of the API the policy applies to."
}

variable "xml_content_api_policy" {
  type        = string
  default     = ""
  description = "The XML policy content to apply to the API."
}

variable "xml_link_api_policy" {
  type        = string
  default     = ""
  description = "The URL link to the XML policy for the API."
}

##-----------------------------------------------------------------------------
## API Management - Named Value
##-----------------------------------------------------------------------------
variable "enable_named_value" {
  type        = bool
  default     = false
  description = "Set to true to create the named value resource."
}

variable "named_value_display_name" {
  type        = string
  default     = ""
  description = "The display name of the named value."
}

variable "named_value_value" {
  type        = string
  default     = ""
  description = "The value of the named value."
}

variable "named_value_secret" {
  type        = bool
  default     = false
  description = "Whether the named value is a secret."
}

variable "identity_client_id" {
  type        = string
  default     = ""
  description = "The client ID of the managed identity used to read from Key Vault."
}

variable "secret_id" {
  type        = string
  default     = ""
  description = "The Key Vault secret ID for the named value."
}

##-----------------------------------------------------------------------------
## API Management - User
##-----------------------------------------------------------------------------
variable "enable_user" {
  type        = bool
  default     = false
  description = "Set to true to create the API Management user resource."
}

variable "user_id" {
  type        = string
  default     = ""
  description = "The ID of the API Management user."
}

variable "first_name" {
  type        = string
  default     = ""
  description = "The first name of the user."
}

variable "last_name" {
  type        = string
  default     = ""
  description = "The last name of the user."
}

variable "email" {
  type        = string
  default     = ""
  description = "The email of the user."
}

variable "user_state" {
  type        = string
  default     = ""
  description = "The state of the user (e.g., active or blocked)."
}

variable "confirmation" {
  type        = string
  default     = null
  description = "Determines the type of confirmation e-mail sent, either 'signup' or 'invite'."
}

variable "note" {
  type        = string
  default     = ""
  description = "Optional note for the user."
}

##-----------------------------------------------------------------------------
## API Management - Product
##-----------------------------------------------------------------------------
variable "enable_product" {
  type        = bool
  default     = false
  description = "Set to true to create the API Management product resource."
}

variable "product_id" {
  type        = string
  default     = "test-product"
  description = "The ID of the API Management product."
}

variable "product_display_name" {
  type        = string
  default     = "Test Product"
  description = "The display name of the API Management product."
}

variable "subscription_required" {
  type        = bool
  default     = true
  description = "Whether a subscription is required to use this product."
}

variable "subscriptions_limit" {
  type        = number
  default     = null
  description = "The number of subscriptions a user can have to this product."
}

variable "terms" {
  type        = string
  default     = null
  description = "The terms of use for the product."
}

variable "approval_required" {
  type        = bool
  default     = true
  description = "Whether subscription approval is required."
}

variable "published" {
  type        = bool
  default     = true
  description = "Whether the product is published."
}

variable "product_description" {
  type        = string
  default     = null
  description = "The description of the product."
}

##-----------------------------------------------------------------------------
## API Management - Subscription
##-----------------------------------------------------------------------------
variable "enable_subscription" {
  type        = bool
  default     = false
  description = "Set to true to create the API Management subscription resource."
}

variable "subscription_user_id" {
  type        = string
  default     = ""
  description = "The ID of the user associated with the subscription."
}

variable "subscription_product_id" {
  type        = string
  default     = ""
  description = "The ID of the product associated with the subscription."
}

variable "subscription_api_id" {
  type        = string
  default     = ""
  description = "The ID of the API associated with the subscription."
}

variable "primary_key" {
  type        = string
  default     = ""
  description = "The primary key for the subscription."
}

variable "secondary_key" {
  type        = string
  default     = ""
  description = "The secondary key for the subscription."
}

variable "subscription_display_name" {
  type        = string
  default     = ""
  description = "The display name of the API Management subscription."
}

variable "subscription_state" {
  type        = string
  default     = ""
  description = "The state of the subscription (e.g., active, suspended)."
}

variable "subscription_id" {
  type        = string
  default     = ""
  description = "The ID of the subscription."
}

variable "allow_tracing" {
  type        = bool
  default     = false
  description = "Indicates whether tracing is enabled for the subscription."
}

##-----------------------------------------------------------------------------
## API Management - API Operation
##-----------------------------------------------------------------------------
variable "enable_api_operation" {
  type        = bool
  default     = false
  description = "Set to true to create the API Management API operation resource."
}

variable "operation_id" {
  type        = string
  default     = ""
  description = "The ID of the API operation."
}

variable "api_name_api_operation" {
  type        = string
  default     = ""
  description = "The name of the API the operation belongs to."
}

variable "operation_display_name" {
  type        = string
  default     = ""
  description = "The display name of the API operation."
}

variable "method" {
  type        = string
  default     = ""
  description = "The HTTP method (GET, POST, DELETE, etc.)."
}

variable "url_template" {
  type        = string
  default     = ""
  description = "The URL template for the operation."
}

variable "operation_description" {
  type        = string
  default     = ""
  description = "The description of the API operation."
}

variable "template_parameter" {
  description = "The template parameter for the API operation."
  type = object({
    name          = string
    type          = string
    required      = bool
    default_value = optional(string)
    description   = optional(string)
    schema_id     = optional(string)
    type_name     = optional(string)
    values        = optional(list(string))
  })
  default = null
}

variable "responses" {
  description = "List of response objects for the API operation."
  type = list(object({
    status_code = number
    description = optional(string)
    representations = optional(list(object({
      content_type = string
      schema_id    = optional(string)
      type_name    = optional(string)
    })), [])
    headers = optional(list(object({
      name          = string
      required      = bool
      default_value = optional(string)
      description   = optional(string)
      schema_id     = optional(string)
      values        = optional(list(string))
      type_name     = optional(string)
      type          = optional(string)
    })), [])
  }))
  default = []
}

variable "request" {
  description = "Request configuration for the API operation."
  type = object({
    description = optional(string)
    representations = optional(list(object({
      content_type = string
      schema_id    = optional(string)
      type_name    = optional(string)
    })), [])
    query_parameters = optional(list(object({
      name          = string
      required      = bool
      default_value = optional(string)
      description   = optional(string)
      schema_id     = optional(string)
      values        = optional(list(string))
      type_name     = optional(string)
      type          = optional(string)
    })), [])
    headers = optional(list(object({
      name          = string
      required      = bool
      default_value = optional(string)
      description   = optional(string)
      schema_id     = optional(string)
      values        = optional(list(string))
      type_name     = optional(string)
      type          = optional(string)
    })), [])
  })
  default = null
}

##-----------------------------------------------------------------------------
## API Management - API Operation Tag
##-----------------------------------------------------------------------------
variable "enable_api_operation_tag" {
  type        = bool
  default     = false
  description = "Set to true to create the API Management API operation tag resource."
}

variable "api_operation_id" {
  type        = string
  default     = ""
  description = "The full resource ID of the API operation the tag is attached to."
}

variable "operation_tag_display_name" {
  type        = string
  default     = ""
  description = "The display name of the API operation tag."
}

##-----------------------------------------------------------------------------
## API Management - API Operation Policy
##-----------------------------------------------------------------------------
variable "enable_api_operation_policy" {
  type        = bool
  default     = false
  description = "Set to true to create the API Management API operation policy resource."
}

variable "api_name_api_operation_policy" {
  type        = string
  default     = ""
  description = "The name of the API the operation policy applies to."
}

variable "operation_id_api_operation_policy" {
  type        = string
  default     = ""
  description = "The ID of the API operation the policy applies to."
}

variable "xml_content_api_operation_policy" {
  type        = string
  default     = ""
  description = "The XML policy content for the API operation."
}

variable "xml_link_api_operation_policy" {
  type        = string
  default     = ""
  description = "The URL to an XML policy file for the API operation."
}

##-----------------------------------------------------------------------------
## Private Endpoint & DNS
##-----------------------------------------------------------------------------
variable "enable_private_endpoint" {
  type        = bool
  default     = false
  description = "Enable private endpoint for APIM."
}

variable "private_endpoint_subnet_id" {
  type        = string
  default     = null
  description = "Subnet ID for the private endpoint."
}

variable "private_dns_zone_ids" {
  type        = list(string)
  default     = null
  description = "List of private DNS zone IDs to associate with the APIM private endpoint."
}
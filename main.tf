##-----------------------------------------------------------------------------
## Labels / Tags
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

##-----------------------------------------------------------------------------
## Public IP (only relevant for Developer / Premium SKUs when custom PIP requested)
##-----------------------------------------------------------------------------
resource "azurerm_public_ip" "main" {
  count               = var.enable && var.enable_custom_public_ip && contains(["Developer", "Premium"], split("_", var.sku_name)[0]) ? 1 : 0
  name                = var.resource_position_prefix ? format("pip-%s", local.name) : format("%s-pip", local.name)
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = var.zones
  tags                = module.labels.tags
}

##-----------------------------------------------------------------------------
## API Management
##-----------------------------------------------------------------------------
resource "azurerm_api_management" "main" {
  count                         = var.enable ? 1 : 0
  name                          = var.resource_position_prefix ? format("apim-%s", local.name) : format("%s-apim", local.name)
  location                      = var.location
  resource_group_name           = var.resource_group_name
  publisher_name                = var.publisher_name
  publisher_email               = var.publisher_email
  sku_name                      = var.sku_name
  client_certificate_enabled    = var.client_certificate_enabled
  gateway_disabled              = var.gateway_disabled
  min_api_version               = var.min_api_version
  notification_sender_email     = var.notification_sender_email
  public_ip_address_id          = length(azurerm_public_ip.main) > 0 ? azurerm_public_ip.main[0].id : var.public_ip_address_id
  public_network_access_enabled = var.public_network_access_enabled
  zones                         = var.zones
  virtual_network_type          = var.subnet_id == null ? "None" : var.virtual_network_type
  tags                          = module.labels.tags

  dynamic "virtual_network_configuration" {
    for_each = var.subnet_id == null ? [] : [var.subnet_id]
    content {
      subnet_id = virtual_network_configuration.value
    }
  }

  dynamic "additional_location" {
    for_each = var.additional_location != null ? var.additional_location : []
    content {
      location             = additional_location.value.location
      capacity             = additional_location.value.capacity
      zones                = additional_location.value.zones
      public_ip_address_id = additional_location.value.public_ip_address_id
      gateway_disabled     = additional_location.value.gateway_disabled

      dynamic "virtual_network_configuration" {
        for_each = additional_location.value.virtual_network_configuration != null ? [additional_location.value.virtual_network_configuration] : []
        content {
          subnet_id = virtual_network_configuration.value.subnet_id
        }
      }
    }
  }

  dynamic "certificate" {
    for_each = var.certificate != null ? var.certificate : []
    content {
      encoded_certificate  = certificate.value.encoded_certificate
      store_name           = certificate.value.store_name
      certificate_password = certificate.value.certificate_password
    }
  }

  dynamic "protocols" {
    for_each = var.protocols != null ? [var.protocols] : []
    content {
      http2_enabled = protocols.value.http2_enabled
    }
  }

  dynamic "hostname_configuration" {
    for_each = var.hostname_configuration != null ? [var.hostname_configuration] : []
    content {
      dynamic "management" {
        for_each = try(hostname_configuration.value.management, [])
        content {
          host_name                       = management.value.host_name
          key_vault_certificate_id        = management.value.key_vault_certificate_id
          certificate                     = management.value.certificate
          certificate_password            = management.value.certificate_password
          negotiate_client_certificate    = management.value.negotiate_client_certificate
          ssl_keyvault_identity_client_id = management.value.ssl_keyvault_identity_client_id
        }
      }

      dynamic "portal" {
        for_each = try(hostname_configuration.value.portal, [])
        content {
          host_name                       = portal.value.host_name
          key_vault_certificate_id        = portal.value.key_vault_certificate_id
          certificate                     = portal.value.certificate
          certificate_password            = portal.value.certificate_password
          negotiate_client_certificate    = portal.value.negotiate_client_certificate
          ssl_keyvault_identity_client_id = portal.value.ssl_keyvault_identity_client_id
        }
      }

      dynamic "developer_portal" {
        for_each = try(hostname_configuration.value.developer_portal, [])
        content {
          host_name                       = developer_portal.value.host_name
          key_vault_certificate_id        = developer_portal.value.key_vault_certificate_id
          certificate                     = developer_portal.value.certificate
          certificate_password            = developer_portal.value.certificate_password
          negotiate_client_certificate    = developer_portal.value.negotiate_client_certificate
          ssl_keyvault_identity_client_id = developer_portal.value.ssl_keyvault_identity_client_id
        }
      }

      dynamic "proxy" {
        for_each = try(hostname_configuration.value.proxy, [])
        content {
          default_ssl_binding             = proxy.value.default_ssl_binding
          host_name                       = proxy.value.host_name
          key_vault_certificate_id        = proxy.value.key_vault_certificate_id
          certificate                     = proxy.value.certificate
          certificate_password            = proxy.value.certificate_password
          negotiate_client_certificate    = proxy.value.negotiate_client_certificate
          ssl_keyvault_identity_client_id = proxy.value.ssl_keyvault_identity_client_id
        }
      }

      dynamic "scm" {
        for_each = try(hostname_configuration.value.scm, [])
        content {
          host_name                       = scm.value.host_name
          key_vault_certificate_id        = scm.value.key_vault_certificate_id
          certificate                     = scm.value.certificate
          certificate_password            = scm.value.certificate_password
          negotiate_client_certificate    = scm.value.negotiate_client_certificate
          ssl_keyvault_identity_client_id = scm.value.ssl_keyvault_identity_client_id
        }
      }
    }
  }

  dynamic "delegation" {
    for_each = var.delegation != null ? [var.delegation] : []
    content {
      subscriptions_enabled     = delegation.value.subscriptions_enabled
      user_registration_enabled = delegation.value.user_registration_enabled
      url                       = delegation.value.url
      validation_key            = delegation.value.validation_key
    }
  }

  dynamic "sign_in" {
    for_each = var.sign_in != null ? [var.sign_in] : []
    content {
      enabled = sign_in.value.enabled
    }
  }

  dynamic "sign_up" {
    for_each = var.sign_up != null ? [var.sign_up] : []
    content {
      enabled = sign_up.value.enabled

      terms_of_service {
        enabled          = sign_up.value.terms_of_service.enabled
        consent_required = sign_up.value.terms_of_service.consent_required
        text             = sign_up.value.terms_of_service.text
      }
    }
  }

  dynamic "tenant_access" {
    for_each = var.tenant_access != null ? [var.tenant_access] : []
    content {
      enabled = tenant_access.value.enabled
    }
  }

  dynamic "security" {
    for_each = var.security != null ? [var.security] : []
    content {
      backend_ssl30_enabled                               = security.value.backend_ssl30_enabled
      backend_tls10_enabled                               = security.value.backend_tls10_enabled
      backend_tls11_enabled                               = security.value.backend_tls11_enabled
      frontend_ssl30_enabled                              = security.value.frontend_ssl30_enabled
      frontend_tls10_enabled                              = security.value.frontend_tls10_enabled
      frontend_tls11_enabled                              = security.value.frontend_tls11_enabled
      tls_ecdhe_ecdsa_with_aes128_cbc_sha_ciphers_enabled = security.value.tls_ecdhe_ecdsa_with_aes128_cbc_sha_ciphers_enabled
      tls_ecdhe_ecdsa_with_aes256_cbc_sha_ciphers_enabled = security.value.tls_ecdhe_ecdsa_with_aes256_cbc_sha_ciphers_enabled
      tls_ecdhe_rsa_with_aes128_cbc_sha_ciphers_enabled   = security.value.tls_ecdhe_rsa_with_aes128_cbc_sha_ciphers_enabled
      tls_ecdhe_rsa_with_aes256_cbc_sha_ciphers_enabled   = security.value.tls_ecdhe_rsa_with_aes256_cbc_sha_ciphers_enabled
      tls_rsa_with_aes128_cbc_sha256_ciphers_enabled      = security.value.tls_rsa_with_aes128_cbc_sha256_ciphers_enabled
      tls_rsa_with_aes128_cbc_sha_ciphers_enabled         = security.value.tls_rsa_with_aes128_cbc_sha_ciphers_enabled
      tls_rsa_with_aes128_gcm_sha256_ciphers_enabled      = security.value.tls_rsa_with_aes128_gcm_sha256_ciphers_enabled
      tls_rsa_with_aes256_gcm_sha384_ciphers_enabled      = security.value.tls_rsa_with_aes256_gcm_sha384_ciphers_enabled
      tls_rsa_with_aes256_cbc_sha256_ciphers_enabled      = security.value.tls_rsa_with_aes256_cbc_sha256_ciphers_enabled
      tls_rsa_with_aes256_cbc_sha_ciphers_enabled         = security.value.tls_rsa_with_aes256_cbc_sha_ciphers_enabled
      triple_des_ciphers_enabled                          = security.value.triple_des_ciphers_enabled
    }
  }

  dynamic "identity" {
    for_each = var.identity_type != null ? [1] : []
    content {
      type         = var.identity_type
      identity_ids = var.identity_type == "UserAssigned" || var.identity_type == "SystemAssigned, UserAssigned" ? var.identity_ids : null
    }
  }

  dynamic "timeouts" {
    for_each = var.timeouts != null ? [var.timeouts] : []
    content {
      create = timeouts.value.create
      read   = timeouts.value.read
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }

  lifecycle {
    ignore_changes = [tags["created_date"]]
  }
}

##-----------------------------------------------------------------------------
## API Management - Service Policy
##-----------------------------------------------------------------------------
resource "azurerm_api_management_policy" "main" {
  count             = var.enable && var.policy_xml != null ? 1 : 0
  api_management_id = azurerm_api_management.main[0].id
  xml_content       = var.policy_xml
}

##-----------------------------------------------------------------------------
## API Management - Logger (Application Insights)
##-----------------------------------------------------------------------------
resource "azurerm_api_management_logger" "main" {
  count               = var.enable && var.enable_logger ? 1 : 0
  name                = var.logger_name != null ? var.logger_name : (var.resource_position_prefix ? format("apim-logger-%s", local.name) : format("%s-apim-logger", local.name))
  api_management_name = azurerm_api_management.main[0].name
  resource_group_name = var.resource_group_name
  resource_id         = local.app_insights_id

  application_insights {
    instrumentation_key = local.app_insights_instrumentation_key
  }
}

##-----------------------------------------------------------------------------
## API Management - Diagnostic Settings
##-----------------------------------------------------------------------------
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

##-----------------------------------------------------------------------------
## Application Insights (created only when no external instance is supplied)
##-----------------------------------------------------------------------------
resource "azurerm_application_insights" "main" {
  count               = var.enable && var.application_insights_enabled && var.application_insights_id == null ? 1 : 0
  name                = var.resource_position_prefix ? format("appi-%s", local.name) : format("%s-appi", local.name)
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = var.application_insights_type
  sampling_percentage = var.application_insights_sampling_percentage
  retention_in_days   = var.retention_in_days
  ip_masking_enabled  = var.ip_masking_enabled
  workspace_id        = var.log_analytics_workspace_id
  tags                = module.labels.tags
}

##-----------------------------------------------------------------------------
## API Management - APIs
##-----------------------------------------------------------------------------
resource "azurerm_api_management_api" "main" {
  for_each = var.enable && var.enable_api_management_api ? { for api in var.apis : api.name => api } : {}

  name                  = each.value.name
  resource_group_name   = var.resource_group_name
  api_management_name   = azurerm_api_management.main[0].name
  revision              = each.value.revision
  display_name          = each.value.display_name
  path                  = each.value.path
  protocols             = each.value.protocols
  api_type              = each.value.api_type
  service_url           = each.value.service_url
  revision_description  = each.value.revision_description
  description           = each.value.description
  subscription_required = each.value.subscription_required
  terms_of_service_url  = each.value.terms_of_service_url
  version               = each.value.version
  version_description   = each.value.version_description
  version_set_id        = each.value.version_set_id

  dynamic "import" {
    for_each = each.value.import != null ? [each.value.import] : []
    content {
      content_format = import.value.content_format
      content_value  = import.value.content_value

      dynamic "wsdl_selector" {
        for_each = import.value.wsdl_selector != null ? import.value.wsdl_selector : []
        content {
          service_name  = wsdl_selector.value.service_name
          endpoint_name = wsdl_selector.value.endpoint_name
        }
      }
    }
  }

  dynamic "oauth2_authorization" {
    for_each = each.value.oauth2_authorization != null ? [each.value.oauth2_authorization] : []
    content {
      authorization_server_name = oauth2_authorization.value.authorization_server_name
      scope                     = oauth2_authorization.value.scope
    }
  }

  dynamic "openid_authentication" {
    for_each = each.value.openid_authentication != null ? [each.value.openid_authentication] : []
    content {
      openid_provider_name         = openid_authentication.value.openid_provider_name
      bearer_token_sending_methods = openid_authentication.value.bearer_token_sending_methods
    }
  }
}

##-----------------------------------------------------------------------------
## API Management - API Version Set
##-----------------------------------------------------------------------------
resource "azurerm_api_management_api_version_set" "main" {
  count               = var.enable && var.enable_api_version_set ? 1 : 0
  name                = var.resource_position_prefix ? format("apim-avs-%s", local.name) : format("%s-apim-avs", local.name)
  resource_group_name = var.resource_group_name
  api_management_name = azurerm_api_management.main[0].name
  display_name        = var.api_version_set_display_name
  versioning_scheme   = var.versioning_scheme

  description         = lookup(var.api_version_set_optional_fields, "description", null)
  version_header_name = lookup(var.api_version_set_optional_fields, "version_header_name", null)
  version_query_name  = lookup(var.api_version_set_optional_fields, "version_query_name", null)
}

##-----------------------------------------------------------------------------
## API Management - API Policy
##-----------------------------------------------------------------------------
resource "azurerm_api_management_api_policy" "main" {
  count               = var.enable && var.enable_api_policy ? 1 : 0
  api_name            = var.api_name_api_policy
  api_management_name = azurerm_api_management.main[0].name
  resource_group_name = var.resource_group_name

  xml_link    = var.xml_link_api_policy
  xml_content = var.xml_content_api_policy
}

##-----------------------------------------------------------------------------
## API Management - Named Value
##-----------------------------------------------------------------------------
resource "azurerm_api_management_named_value" "main" {
  count               = var.enable && var.enable_named_value ? 1 : 0
  name                = var.resource_position_prefix ? format("apim-nv-%s", local.name) : format("%s-apim-nv", local.name)
  api_management_name = azurerm_api_management.main[0].name
  resource_group_name = var.resource_group_name
  display_name        = var.named_value_display_name
  value               = var.named_value_value
  secret              = var.named_value_secret

  dynamic "value_from_key_vault" {
    for_each = var.named_value_secret ? [1] : []
    content {
      identity_client_id = var.identity_client_id
      secret_id          = var.secret_id
    }
  }
}

##-----------------------------------------------------------------------------
## API Management - User
##-----------------------------------------------------------------------------
resource "azurerm_api_management_user" "main" {
  count               = var.enable && var.enable_user ? 1 : 0
  user_id             = var.user_id
  api_management_name = azurerm_api_management.main[0].name
  resource_group_name = var.resource_group_name
  first_name          = var.first_name
  last_name           = var.last_name
  email               = var.email
  state               = var.user_state
  confirmation        = var.confirmation
  note                = var.note
}

##-----------------------------------------------------------------------------
## API Management - Product
##-----------------------------------------------------------------------------
resource "azurerm_api_management_product" "main" {
  count                 = var.enable && var.enable_product ? 1 : 0
  product_id            = var.product_id
  api_management_name   = azurerm_api_management.main[0].name
  resource_group_name   = var.resource_group_name
  display_name          = var.product_display_name
  subscription_required = var.subscription_required
  subscriptions_limit   = var.subscriptions_limit
  terms                 = var.terms
  approval_required     = var.approval_required
  published             = var.published
  description           = var.product_description
}

##-----------------------------------------------------------------------------
## API Management - Subscription
##-----------------------------------------------------------------------------
resource "azurerm_api_management_subscription" "main" {
  count               = var.enable && var.enable_subscription ? 1 : 0
  api_management_name = azurerm_api_management.main[0].name
  resource_group_name = var.resource_group_name
  user_id             = var.subscription_user_id
  product_id          = var.subscription_product_id
  display_name        = var.subscription_display_name
  api_id              = var.subscription_api_id
  primary_key         = var.primary_key
  secondary_key       = var.secondary_key
  state               = var.subscription_state
  subscription_id     = var.subscription_id
  allow_tracing       = var.allow_tracing
}

##-----------------------------------------------------------------------------
## API Management - API Operation
##-----------------------------------------------------------------------------
resource "azurerm_api_management_api_operation" "main" {
  count               = var.enable && var.enable_api_operation ? 1 : 0
  operation_id        = var.operation_id
  api_name            = var.api_name_api_operation
  api_management_name = azurerm_api_management.main[0].name
  resource_group_name = var.resource_group_name
  display_name        = var.operation_display_name
  method              = var.method
  url_template        = var.url_template
  description         = var.operation_description

  dynamic "template_parameter" {
    for_each = var.template_parameter != null ? [var.template_parameter] : []
    content {
      name          = template_parameter.value.name
      type          = template_parameter.value.type
      required      = template_parameter.value.required
      default_value = template_parameter.value.default_value
      description   = template_parameter.value.description
      schema_id     = template_parameter.value.schema_id
      type_name     = template_parameter.value.type_name
      values        = template_parameter.value.values
    }
  }

  dynamic "response" {
    for_each = var.responses
    content {
      status_code = response.value.status_code
      description = response.value.description

      dynamic "representation" {
        for_each = response.value.representations
        content {
          content_type = representation.value.content_type
          schema_id    = representation.value.schema_id
          type_name    = representation.value.type_name
        }
      }

      dynamic "header" {
        for_each = response.value.headers
        content {
          name          = header.value.name
          required      = header.value.required
          default_value = header.value.default_value
          description   = header.value.description
          schema_id     = header.value.schema_id
          values        = header.value.values
          type_name     = header.value.type_name
          type          = header.value.type
        }
      }
    }
  }

  dynamic "request" {
    for_each = var.request != null ? [var.request] : []
    content {
      description = request.value.description

      dynamic "representation" {
        for_each = request.value.representations
        content {
          content_type = representation.value.content_type
          schema_id    = representation.value.schema_id
          type_name    = representation.value.type_name
        }
      }

      dynamic "query_parameter" {
        for_each = request.value.query_parameters
        content {
          name          = query_parameter.value.name
          required      = query_parameter.value.required
          default_value = query_parameter.value.default_value
          description   = query_parameter.value.description
          schema_id     = query_parameter.value.schema_id
          values        = query_parameter.value.values
          type_name     = query_parameter.value.type_name
          type          = query_parameter.value.type
        }
      }

      dynamic "header" {
        for_each = request.value.headers
        content {
          name          = header.value.name
          required      = header.value.required
          default_value = header.value.default_value
          description   = header.value.description
          schema_id     = header.value.schema_id
          values        = header.value.values
          type_name     = header.value.type_name
          type          = header.value.type
        }
      }
    }
  }
}

##-----------------------------------------------------------------------------
## API Management - API Operation Tag
##-----------------------------------------------------------------------------
resource "azurerm_api_management_api_operation_tag" "main" {
  count            = var.enable && var.enable_api_operation_tag ? 1 : 0
  name             = var.resource_position_prefix ? format("apim-aot-%s", local.name) : format("%s-apim-aot", local.name)
  api_operation_id = var.api_operation_id
  display_name     = var.operation_tag_display_name
}

##-----------------------------------------------------------------------------
## API Management - API Operation Policy
##-----------------------------------------------------------------------------
resource "azurerm_api_management_api_operation_policy" "main" {
  count               = var.enable && var.enable_api_operation_policy ? 1 : 0
  api_name            = var.api_name_api_operation_policy
  api_management_name = azurerm_api_management.main[0].name
  resource_group_name = var.resource_group_name
  operation_id        = var.operation_id_api_operation_policy

  xml_content = var.xml_content_api_operation_policy
  xml_link    = var.xml_link_api_operation_policy
}

##-----------------------------------------------------------------------------
## Private Endpoint - Deploy private network access to APIM
##-----------------------------------------------------------------------------
resource "azurerm_private_endpoint" "pep" {
  count               = var.enable && var.enable_private_endpoint ? 1 : 0
  name                = format("pe-%s", azurerm_api_management.main[0].name)
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id
  tags                = module.labels.tags

  private_service_connection {
    name                           = var.resource_position_prefix ? format("psc-apim-%s", local.name) : format("%s-psc-apim", local.name)
    is_manual_connection           = false
    private_connection_resource_id = azurerm_api_management.main[0].id
    subresource_names              = ["Gateway"]
  }

  private_dns_zone_group {
    name                 = var.resource_position_prefix ? format("apim-dns-zone-group-%s", local.name) : format("%s-apim-dns-zone-group", local.name)
    private_dns_zone_ids = var.private_dns_zone_ids
  }

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}
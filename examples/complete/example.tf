provider "azurerm" {
  features {}
}

##-----------------------------------------------------------------------------
## Resources
##-----------------------------------------------------------------------------
module "resource_group" {
  source      = "terraform-az-modules/resource-group/azurerm"
  version     = "1.0.4"
  name        = "core"
  environment = "dev"
  location    = "centralus"
  label_order = ["name", "environment", "location"]
}

module "vnet" {
  source              = "terraform-az-modules/vnet/azurerm"
  version             = "1.0.4"
  name                = "core"
  environment         = "dev"
  label_order         = ["name", "environment", "location"]
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  address_spaces      = ["10.40.0.0/16"]
}

resource "azurerm_network_security_group" "apim" {
  name                = "nsg-apim"
  location            = module.resource_group.resource_group_location
  resource_group_name = module.resource_group.resource_group_name

  security_rule {
    name                       = "AllowApiManagement"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3443"
    source_address_prefix      = "ApiManagement"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "AllowAzureLoadBalancer"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "6390"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "AllowApiManagementClients"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["80", "443"]
    source_address_prefix      = "Internet"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "AllowAzureTrafficManager"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "AzureTrafficManager"
    destination_address_prefix = "VirtualNetwork"
  }
}

module "subnet" {
  source               = "terraform-az-modules/subnet/azurerm"
  version              = "1.0.3"
  environment          = "dev"
  label_order          = ["name", "environment", "location"]
  resource_group_name  = module.resource_group.resource_group_name
  location             = module.resource_group.resource_group_location
  virtual_network_name = module.vnet.vnet_name
  subnets = [
    {
      name                      = "apim"
      subnet_prefixes           = ["10.40.1.0/24"]
      nsg_association           = true
      network_security_group_id = azurerm_network_security_group.apim.id
    }
  ]
}

module "log_analytics" {
  source                      = "terraform-az-modules/log-analytics/azurerm"
  version                     = "2.1.0"
  environment                 = "dev"
  location                    = module.resource_group.resource_group_location
  label_order                 = ["name", "environment", "location"]
  resource_group_name         = module.resource_group.resource_group_name
  log_analytics_workspace_sku = "PerGB2018"
  retention_in_days           = 30
}

module "application_insights" {
  source                     = "terraform-az-modules/application-insights/azurerm"
  version                    = "1.0.2"
  name                       = "core"
  environment                = "dev"
  location                   = module.resource_group.resource_group_location
  label_order                = ["name", "environment", "location"]
  resource_group_name        = module.resource_group.resource_group_name
  workspace_id               = module.log_analytics.workspace_id
  log_analytics_workspace_id = module.log_analytics.workspace_id
  web_test_enable            = false
}

resource "azurerm_public_ip" "apim" {
  name                = "pip-core"
  location            = module.resource_group.resource_group_location
  resource_group_name = module.resource_group.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = "apim-core-dev-cus"
}

module "api_management" {
  source                           = "../../"
  name                             = "core"
  environment                      = "dev"
  location                         = module.resource_group.resource_group_location
  label_order                      = ["name", "environment", "location"]
  resource_group_name              = module.resource_group.resource_group_name
  publisher_name                   = "Terraform Azure Modules"
  publisher_email                  = "example@contoso.com"
  sku_name                         = "Developer_1"
  virtual_network_type             = "External"
  subnet_id                        = module.subnet.subnet_ids["apim"]
  public_ip_address_id             = azurerm_public_ip.apim.id
  enable_logger                    = true
  app_insights_id                  = module.application_insights.app_insights_id
  app_insights_instrumentation_key = module.application_insights.instrumentation_key
  enable_diagnostic                = true
  log_analytics_workspace_id       = module.log_analytics.workspace_id
  policy_xml                       = <<XML
<policies>
  <inbound>
    <set-header name="X-Example-Module" exists-action="override">
      <value>api-management</value>
    </set-header>
  </inbound>
  <backend>
    <forward-request />
  </backend>
  <outbound />
  <on-error />
</policies>
XML

  depends_on = [module.subnet]
}

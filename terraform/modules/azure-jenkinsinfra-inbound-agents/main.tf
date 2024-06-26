####################################################################################
# Network resources defined in https://github.com/jenkins-infra/azure-net
####################################################################################
data "azurerm_resource_group" "inbound_agents_vnet" {
  name = var.inbound_agents_network_rg_name
}
data "azurerm_virtual_network" "inbound_agents" {
  name                = var.inbound_agents_network_name
  resource_group_name = data.azurerm_resource_group.inbound_agents_vnet.name
}
data "azurerm_subnet" "inbound_agents" {
  name                 = var.inbound_agents_subnet_name
  virtual_network_name = data.azurerm_virtual_network.inbound_agents.name
  resource_group_name  = data.azurerm_resource_group.inbound_agents_vnet.name
}

####################################################################################
## Network Security Group and rules
####################################################################################
resource "azurerm_network_security_group" "inbound_agents" {
  name                = data.azurerm_subnet.inbound_agents.name
  location            = data.azurerm_resource_group.inbound_agents_vnet.location
  resource_group_name = var.controller_rg_name
  tags                = var.default_tags
}
resource "azurerm_subnet_network_security_group_association" "inbound_agents" {
  subnet_id                 = data.azurerm_subnet.inbound_agents.id
  network_security_group_id = azurerm_network_security_group.inbound_agents.id
}
## Outbound Rules (different set of priorities than Inbound rules) ##
#trivy:ignore:azure-network-no-public-egress
resource "azurerm_network_security_rule" "allow_outbound_ssh_from_agents_to_internet" {
  name                        = "allow-out-ssh-from-subnet-to-internet"
  priority                    = 4092
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  source_address_prefixes     = local.agents_cidr
  destination_port_range      = "22"
  destination_address_prefix  = "Internet" # TODO: restrict to GitHub IPs from their meta endpoint (subsection git) - https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/about-githubs-ip-addresses
  resource_group_name         = var.controller_rg_name
  network_security_group_name = azurerm_network_security_group.inbound_agents.name
}
resource "azurerm_network_security_rule" "allow_outbound_jenkins_from_agents_to_controller" {
  name                    = "allow-out-jenkins-from-subnet-to-ctrl"
  priority                = 4093
  direction               = "Outbound"
  access                  = "Allow"
  protocol                = "Tcp"
  source_port_range       = "*"
  source_address_prefixes = local.agents_cidr
  destination_port_ranges = [
    "443",   # HTTPS for secured inbound websocket
    "50000", # Direct TCP Inbound protocol
  ]
  destination_address_prefixes = compact(var.controller_ips)
  resource_group_name          = var.controller_rg_name
  network_security_group_name  = azurerm_network_security_group.inbound_agents.name
}
#trivy:ignore:azure-network-no-public-egress
resource "azurerm_network_security_rule" "allow_outbound_http_from_agents_to_internet" {
  name                    = "allow-out-http-from-subnet-to-internet"
  priority                = 4094
  direction               = "Outbound"
  access                  = "Allow"
  protocol                = "Tcp"
  source_port_range       = "*"
  source_address_prefixes = local.agents_cidr
  destination_port_ranges = [
    "80",  # HTTP
    "443", # HTTPS
  ]
  destination_address_prefix  = "Internet"
  resource_group_name         = var.controller_rg_name
  network_security_group_name = azurerm_network_security_group.inbound_agents.name
}
resource "azurerm_network_security_rule" "deny_all_outbound_from_agents_to_internet" {
  name                        = "deny-all-out-from-subnet-to-internet"
  priority                    = 4095
  direction                   = "Outbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefixes     = local.agents_cidr
  destination_address_prefix  = "Internet"
  resource_group_name         = var.controller_rg_name
  network_security_group_name = azurerm_network_security_group.inbound_agents.name
}
# This rule overrides an Azure-Default rule. its priority must be < 65000.
resource "azurerm_network_security_rule" "deny_all_outbound_from_agents_to_vnet" {
  name                        = "deny-all-out-from-subnet-to-vnet"
  priority                    = 4096 # Maximum value allowed by Azure API
  direction                   = "Outbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefixes     = local.agents_cidr
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = var.controller_rg_name
  network_security_group_name = azurerm_network_security_group.inbound_agents.name
}

## Inbound Rules (different set of priorities than Outbound rules) ##
# This rule overrides an Azure-Default rule. its priority must be < 65000
resource "azurerm_network_security_rule" "deny_all_inbound_from_vnet_to_agents" {
  name                         = "deny-all-in-from-vnet-to-subnet"
  priority                     = 4096 # Maximum value allowed by the Azure Terraform Provider
  direction                    = "Inbound"
  access                       = "Deny"
  protocol                     = "*"
  source_port_range            = "*"
  destination_port_range       = "*"
  source_address_prefix        = "*"
  destination_address_prefixes = local.agents_cidr
  resource_group_name          = var.controller_rg_name
  network_security_group_name  = azurerm_network_security_group.inbound_agents.name
}

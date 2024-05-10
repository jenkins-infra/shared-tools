####################################################################################
# Network resources defined in https://github.com/jenkins-infra/azure-net
####################################################################################
data "azurerm_resource_group" "kubernetes_agents_vnet" {
  name = var.kubernetes_agents_network_rg_name
}
data "azurerm_virtual_network" "kubernetes_agents" {
  name                = var.kubernetes_agents_network_name
  resource_group_name = data.azurerm_resource_group.kubernetes_agents_vnet.name
}
data "azurerm_subnet" "kubernetes_agents" {
  name                 = var.kubernetes_agents_subnet_name
  virtual_network_name = data.azurerm_virtual_network.kubernetes_agents.name
  resource_group_name  = data.azurerm_resource_group.kubernetes_agents_vnet.name
}

####################################################################################
## Network Security Group and rules
####################################################################################
resource "azurerm_network_security_group" "kubernetes_agents" {
  name                = local.nsg_agent_short_stripped_name
  location            = data.azurerm_resource_group.kubernetes_agents_vnet.location
  resource_group_name = var.controller_rg_name
  tags                = var.default_tags
}
resource "azurerm_subnet_network_security_group_association" "kubernetes_agents" {
  subnet_id                 = data.azurerm_subnet.kubernetes_agents.id
  network_security_group_id = azurerm_network_security_group.kubernetes_agents.id
}
## Outbound Rules (different set of priorities than Inbound rules) ##
#trivy:ignore:azure-network-no-public-egress
resource "azurerm_network_security_rule" "allow_outbound_ssh_from_kubernetes_agents_to_internet" {
  name                        = "allow-out-ssh-from-${local.nsg_agent_short_stripped_name}-to-internet"
  priority                    = 4092
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  source_address_prefixes     = data.azurerm_subnet.kubernetes_agents.address_prefixes
  destination_port_range      = "22"
  destination_address_prefix  = "Internet" # TODO: restrict to GitHub IPs from their meta endpoint (subsection git) - https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/about-githubs-ip-addresses
  resource_group_name         = var.controller_rg_name
  network_security_group_name = azurerm_network_security_group.kubernetes_agents.name
}
resource "azurerm_network_security_rule" "allow_outbound_jenkins_from_kubernetes_agents_to_controller" {
  name                    = "allow-out-jenkins-from-${local.service_short_stripped_name}-to-ctrl"
  priority                = 4093
  direction               = "Outbound"
  access                  = "Allow"
  protocol                = "Tcp"
  source_port_range       = "*"
  source_address_prefixes = data.azurerm_subnet.kubernetes_agents.address_prefixes
  destination_port_ranges = [
    "80",    # HTTP for inbound websocket
    "443",   # HTTPS for secured inbound websocket
    "50000", # Direct TCP Inbound protocol
  ]
  destination_address_prefixes = compact(var.controller_ips)
  resource_group_name          = var.controller_rg_name
  network_security_group_name  = azurerm_network_security_group.kubernetes_agents.name
}
#trivy:ignore:azure-network-no-public-egress
resource "azurerm_network_security_rule" "allow_outbound_http_from_kubernetes_agents_to_internet" {
  name                    = "allow-out-http-from-${local.nsg_agent_short_stripped_name}-to-internet"
  priority                = 4094
  direction               = "Outbound"
  access                  = "Allow"
  protocol                = "Tcp"
  source_port_range       = "*"
  source_address_prefixes = data.azurerm_subnet.kubernetes_agents.address_prefixes
  destination_port_ranges = [
    "80",  # HTTP
    "443", # HTTPS
  ]
  destination_address_prefix  = "Internet"
  resource_group_name         = var.controller_rg_name
  network_security_group_name = azurerm_network_security_group.kubernetes_agents.name
}
resource "azurerm_network_security_rule" "deny_all_outbound_from_kubernetes_agents_to_internet" {
  name                        = "deny-all-out-from-${local.nsg_agent_short_stripped_name}-to-internet"
  priority                    = 4095
  direction                   = "Outbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefixes     = data.azurerm_subnet.kubernetes_agents.address_prefixes
  destination_address_prefix  = "Internet"
  resource_group_name         = var.controller_rg_name
  network_security_group_name = azurerm_network_security_group.kubernetes_agents.name
}
# This rule overrides an Azure-Default rule. its priority must be < 65000.
resource "azurerm_network_security_rule" "deny_all_outbound_from_kubernetes_agents_to_vnet" {
  name                        = "deny-all-out-from-${local.nsg_agent_short_stripped_name}-to-vnet"
  priority                    = 4096 # Maximum value allowed by Azure API
  direction                   = "Outbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefixes     = data.azurerm_subnet.kubernetes_agents.address_prefixes
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = var.controller_rg_name
  network_security_group_name = azurerm_network_security_group.kubernetes_agents.name
}

## Inbound Rules (different set of priorities than Outbound rules) ##
# This rule overrides an Azure-Default rule. its priority must be < 65000
resource "azurerm_network_security_rule" "deny_all_inbound_from_vnet_to_kubernetes_agents" {
  name                         = "deny-all-in-from-vnet-to-${local.service_short_stripped_name}_kubernetes_agents"
  priority                     = 4096 # Maximum value allowed by the Azure Terraform Provider
  direction                    = "Inbound"
  access                       = "Deny"
  protocol                     = "*"
  source_port_range            = "*"
  destination_port_range       = "*"
  source_address_prefix        = "*"
  destination_address_prefixes = data.azurerm_subnet.kubernetes_agents.address_prefixes
  resource_group_name          = var.controller_rg_name
  network_security_group_name  = azurerm_network_security_group.kubernetes_agents.name
}

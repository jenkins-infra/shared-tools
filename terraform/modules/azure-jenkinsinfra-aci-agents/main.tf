####################################################################################
## Azurerm Resources for the ACI Agents (Azure Container Instance plugin)
####################################################################################
data "azurerm_resource_group" "aci_agents" {
  name = var.aci_agents_resource_group_name
}

####################################################################################
## Shared data inside the Jenkins Infra
####################################################################################
module "jenkins_infra_shared_data" {
  source = "../jenkins-infra-shared-data"
}

####################################################################################
# Network resources defined in https://github.com/jenkins-infra/azure-net
####################################################################################
data "azurerm_resource_group" "aci_agents_vnet" {
  name = var.aci_agents_network_rg_name
}
data "azurerm_virtual_network" "aci_agents" {
  name                = var.aci_agents_network_name
  resource_group_name = data.azurerm_resource_group.aci_agents_vnet.name
}
data "azurerm_subnet" "aci_agents" {
  name                 = var.aci_agents_subnet_name
  virtual_network_name = data.azurerm_virtual_network.aci_agents.name
  resource_group_name  = data.azurerm_resource_group.aci_agents_vnet.name
}


####################################################################################
## Azure Active Directory Resources to allow controller spawning ACI agents
####################################################################################
resource "azurerm_role_definition" "aci_agents_aci_contributor" {
  name  = "${var.service_fqdn}-ACI-Contributor"
  scope = data.azurerm_resource_group.aci_agents.id

  permissions {
    actions = [
      # https://learn.microsoft.com/en-us/azure/role-based-access-control/resource-provider-operations#microsoftcontainerinstance
      "Microsoft.ContainerInstance/containerGroups/*",
    ]
  }
}
resource "azurerm_role_assignment" "controller_aci_agents_aci_contributor" {
  scope                            = data.azurerm_resource_group.aci_agents.id
  role_definition_id               = azurerm_role_definition.aci_agents_aci_contributor.role_definition_resource_id
  principal_id                     = var.controller_service_principal_id
  skip_service_principal_aad_check = true
}
resource "azurerm_role_assignment" "controller_aci_agents_network_contributor" {
  scope                            = data.azurerm_subnet.aci_agents.id
  principal_id                     = var.controller_service_principal_id
  role_definition_name             = "Network Contributor"
  skip_service_principal_aad_check = true
}

####################################################################################
## Network Security Group and rules
####################################################################################
### Ephemeral Agents
resource "azurerm_network_security_group" "aci_agents" {
  name                = "${var.service_fqdn}-aciagents"
  location            = data.azurerm_resource_group.aci_agents_vnet.location
  resource_group_name = var.controller_rg_name
  tags                = var.default_tags
}
resource "azurerm_subnet_network_security_group_association" "aci_agents" {
  subnet_id                 = data.azurerm_subnet.aci_agents.id
  network_security_group_id = azurerm_network_security_group.aci_agents.id
}

## Outbound Rules (different set of priorities than Inbound rules) ##
resource "azurerm_network_security_rule" "allow_out_http_from_aci_agents_to_acp" {
  name                         = "allow-out-http-from-aci_agents-to-acp"
  priority                     = 4049
  direction                    = "Outbound"
  access                       = "Allow"
  protocol                     = "Tcp"
  source_port_range            = "*"
  destination_port_range       = "8080"
  source_address_prefixes      = data.azurerm_subnet.aci_agents.address_prefixes
  destination_address_prefixes = var.jenkins_infra_ips.acp_service_ips
  resource_group_name          = var.controller_rg_name
  network_security_group_name  = azurerm_network_security_group.aci_agents.name
}
#trivy:ignore:azure-network-no-public-egress
resource "azurerm_network_security_rule" "allow_outbound_ssh_from_aci_agents_to_internet" {
  name                        = "allow-outbound-ssh-from-${var.service_short_stripped_name}_aci_agents-to-internet"
  priority                    = 4092
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  source_address_prefixes     = data.azurerm_subnet.aci_agents.address_prefixes
  destination_port_range      = "22"
  destination_address_prefix  = "Internet" # TODO: restrict to GitHub IPs from their meta endpoint (subsection git) - https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/about-githubs-ip-addresses
  resource_group_name         = var.controller_rg_name
  network_security_group_name = azurerm_network_security_group.aci_agents.name
}
#trivy:ignore:azure-network-no-public-egress
resource "azurerm_network_security_rule" "allow_outbound_jenkins_from_aci_agents_to_controller" {
  name                    = "allow-outbound-jenkins-from-${var.service_short_stripped_name}-agents"
  priority                = 4093
  direction               = "Outbound"
  access                  = "Allow"
  protocol                = "Tcp"
  source_port_range       = "*"
  source_address_prefixes = data.azurerm_subnet.aci_agents.address_prefixes
  destination_port_ranges = [
    "80",    # HTTP
    "443",   # HTTPS
    "50000", # Direct TCP Inbound protocol
  ]
  destination_address_prefixes = compact(var.controller_ips)
  resource_group_name          = var.controller_rg_name
  network_security_group_name  = azurerm_network_security_group.aci_agents.name
}
#trivy:ignore:azure-network-no-public-egress
resource "azurerm_network_security_rule" "allow_outbound_http_from_aci_agents_to_internet" {
  name                    = "allow-outbound-http-from-${var.service_short_stripped_name}_aci_agents-to-internet"
  priority                = 4094
  direction               = "Outbound"
  access                  = "Allow"
  protocol                = "Tcp"
  source_port_range       = "*"
  source_address_prefixes = data.azurerm_subnet.aci_agents.address_prefixes
  destination_port_ranges = [
    "80",  # HTTP
    "443", # HTTPS
  ]
  destination_address_prefix  = "Internet"
  resource_group_name         = var.controller_rg_name
  network_security_group_name = azurerm_network_security_group.aci_agents.name
}
resource "azurerm_network_security_rule" "deny_all_outbound_from_aci_agents_to_internet" {
  name                        = "deny-all-outbound-from-${var.service_short_stripped_name}_aci_agents-to-internet"
  priority                    = 4095
  direction                   = "Outbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefixes     = data.azurerm_subnet.aci_agents.address_prefixes
  destination_address_prefix  = "Internet"
  resource_group_name         = var.controller_rg_name
  network_security_group_name = azurerm_network_security_group.aci_agents.name
}
# This rule overrides an Azure-Default rule. its priority must be < 65000.
resource "azurerm_network_security_rule" "deny_all_outbound_from_aci_agents_to_vnet" {
  name                        = "deny-all-outbound-from-${var.service_short_stripped_name}_aci_agents-to-vnet"
  priority                    = 4096 # Maximum value allowed by Azure API
  direction                   = "Outbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefixes     = data.azurerm_subnet.aci_agents.address_prefixes
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = var.controller_rg_name
  network_security_group_name = azurerm_network_security_group.aci_agents.name
}

## Inbound Rules (different set of priorities than Outbound rules) ##
resource "azurerm_network_security_rule" "allow_in_http_from_cijio_agents_to_acp" {
  name                         = "allow-in-http-from-aci_agents-to-acp"
  priority                     = 4049
  direction                    = "Inbound"
  access                       = "Allow"
  protocol                     = "Tcp"
  source_port_range            = "*"
  destination_port_range       = "8080"
  source_address_prefixes      = data.azurerm_subnet.aci_agents.address_prefixes
  destination_address_prefixes = var.jenkins_infra_ips.acp_service_ips
  resource_group_name          = var.controller_rg_name
  network_security_group_name  = azurerm_network_security_group.aci_agents.name
}
resource "azurerm_network_security_rule" "allow_inbound_ssh_from_privatevpn_to_aci_agents" {
  name                        = "allow-inbound-ssh-from-privatevpn-to-${var.service_short_stripped_name}-aci-agents"
  priority                    = 4085
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefixes     = var.jenkins_infra_ips.privatevpn_subnet
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = var.controller_rg_name
  network_security_group_name = azurerm_network_security_group.aci_agents.name
}
resource "azurerm_network_security_rule" "allow_inbound_ssh_from_controller_to_aci_agents" {
  name                         = "allow-inbound-ssh-from-${var.service_short_stripped_name}-controller-to-aci-agents"
  priority                     = 4090
  direction                    = "Inbound"
  access                       = "Allow"
  protocol                     = "Tcp"
  source_port_range            = "*"
  source_address_prefixes      = var.controller_ips
  destination_port_range       = "22" # SSH
  destination_address_prefixes = data.azurerm_subnet.aci_agents.address_prefixes
  resource_group_name          = var.controller_rg_name
  network_security_group_name  = azurerm_network_security_group.aci_agents.name
}
# This rule overrides an Azure-Default rule. its priority must be < 65000
resource "azurerm_network_security_rule" "deny_all_inbound_from_vnet_to_aci_agents" {
  name                         = "deny-all-inbound-from-vnet-to-${var.service_short_stripped_name}_aci_agents"
  priority                     = 4096 # Maximum value allowed by the Azure Terraform Provider
  direction                    = "Inbound"
  access                       = "Deny"
  protocol                     = "*"
  source_port_range            = "*"
  destination_port_range       = "*"
  source_address_prefix        = "*"
  destination_address_prefixes = data.azurerm_subnet.aci_agents.address_prefixes
  resource_group_name          = var.controller_rg_name
  network_security_group_name  = azurerm_network_security_group.aci_agents.name
}

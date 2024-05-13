locals {
  stripped_short_service_name = replace(replace(var.service_fqdn, ".", "-"), "jenkinsio", "jio")
  agents_cidr                 = length(var.inbound_agents_cidrs) == 0 ? data.azurerm_subnet.inbound_agents.address_prefixes : var.inbound_agents_cidrs
}

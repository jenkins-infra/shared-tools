output "controller_resourcegroup_name" {
  value = azurerm_resource_group.controller.name
}

output "ephemeral_agents_resourcegroup_name" {
  value = azurerm_resource_group.ephemeral_agents.name
}

output "controller_public_ipv4" {
  value = var.is_public ? azurerm_public_ip.controller[0].ip_address : azurerm_linux_virtual_machine.controller.private_ip_address
}

output "controller_private_ipv4" {
  value = azurerm_linux_virtual_machine.controller.private_ip_address
}

output "controller_public_fqdn" {
  value = var.is_public ? azurerm_dns_a_record.controller[0].fqdn : var.service_fqdn
}

output "controller_private_fqdn" {
  value = var.is_public ? azurerm_dns_a_record.private_controller[0].fqdn : var.service_fqdn
}

output "service_fqdn" {
  value = var.service_fqdn
}

output "controller_nsg_name" {
  value = azurerm_network_security_group.controller.name
}

output "controller_nsg_id" {
  value = azurerm_network_security_group.controller.id
}

output "ephemeral_agents_nsg_name" {
  value = azurerm_network_security_group.ephemeral_agents.name
}

# TODO: remove once migration finished
output "ephemeral_agents_subnet_prefixes" {
  value = data.azurerm_subnet.ephemeral_agents.address_prefixes
}

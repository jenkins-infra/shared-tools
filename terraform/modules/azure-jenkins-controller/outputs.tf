output "controller_resourcegroup_name" {
  value = azurerm_resource_group.controller.name
}

output "controller_public_ipv4" {
  value = var.is_public ? azurerm_public_ip.controller[0].ip_address : azurerm_linux_virtual_machine.controller.private_ip_address
}

output "controller_private_ipv4" {
  value = azurerm_linux_virtual_machine.controller.private_ip_address
}

output "controller_public_fqdn" {
  value = azurerm_dns_a_record.controller.fqdn
}

output "controller_private_fqdn" {
  value = var.is_public ? azurerm_dns_a_record.private_controller[0].fqdn : azurerm_dns_a_record.controller.fqdn
}

output "service_short_hostname" {
  value = var.controller_short_hostname
}

output "service_fqdn" {
  value = local.service_fqdn
}

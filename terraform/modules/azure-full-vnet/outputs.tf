output "vnet_id" {
  value = azurerm_virtual_network.vnet.id
}

output "vnet_name" {
  value = azurerm_virtual_network.vnet.name
}

output "vnet_rg_name" {
  value = local.rg_name
}

output "vnet_address_space" {
  value = azurerm_virtual_network.vnet.address_space
}

output "subnets" {
  value = { for index, subnet in azurerm_subnet.vnet_subnets : subnet.name => subnet.id }
}

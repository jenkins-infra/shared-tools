# Exported to allow adding additional custom security rules
output "inbound_agents_nsg_name" {
  value = azurerm_network_security_group.inbound_agents.name
}
output "inbound_agents_nsg_rg_name" {
  value = azurerm_network_security_group.inbound_agents.resource_group_name
}

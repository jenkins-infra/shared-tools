# Exported to allow adding additional custom security rules
output "inbound_agents_nsg_name" {
  value = azurerm_network_security_group.inbound_agents.name
}

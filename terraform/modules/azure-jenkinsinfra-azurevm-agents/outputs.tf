output "ephemeral_agents_nsg_name" {
  value = azurerm_network_security_group.ephemeral_agents.name
}

output "ephemeral_agents_resource_group_name" {
  value = azurerm_resource_group.ephemeral_agents.name
}

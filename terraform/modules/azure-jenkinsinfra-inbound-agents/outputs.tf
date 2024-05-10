# Exported to allow adding additional custom security rules
output "kubernetes_agents_nsg_name" {
  value = azurerm_network_security_group.kubernetes_agents.name
}

output "aci_role_id" {
  value = azurerm_role_assignment.controller_ephemeral_agents_aci_contributor.role_definition_id
}

data "azurerm_resource_group" "aci_agents" {
  name = var.aci_agents_resource_group_name
}

####################################################################################
## Azure Active Directory Resources to allow controller spawning ACI agents
####################################################################################
resource "azurerm_role_definition" "ephemeral_agents_aci_contributor" {
  name  = var.role_name
  scope = data.azurerm_resource_group.aci_agents.id

  permissions {
    actions = [
      # https://learn.microsoft.com/en-us/azure/role-based-access-control/resource-provider-operations#microsoftcontainerinstance
      "Microsoft.ContainerInstance/containerGroups/*",
    ]
  }
}
resource "azurerm_role_assignment" "controller_ephemeral_agents_aci_contributor" {
  scope              = data.azurerm_resource_group.aci_agents.id
  role_definition_id = azurerm_role_definition.ephemeral_agents_aci_contributor.role_definition_resource_id
  principal_id       = var.controller_service_principal_id
}

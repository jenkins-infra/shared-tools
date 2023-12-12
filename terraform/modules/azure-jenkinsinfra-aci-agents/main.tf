data "azurerm_resource_group" "aci_agents" {
  name = var.aci_agents_resource_group_name
}

####################################################################################
## Azure Active Directory Resources to allow controller spawning ACI agents
####################################################################################
resource "azurerm_role_definition" "ephemeral_agents_aci_contributor" {
  # Create resource only if user does not specify a custom role ID
  count = var.custom_role_id == "" ? 1 : 0
  name  = "${var.service_short_stripped_name}-ACI-Contributor"
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
  role_definition_id = var.custom_role_id != "" ? var.custom_role_id == "" : azurerm_role_definition.ephemeral_agents_aci_contributor[0].role_definition_resource_id
  principal_id       = var.controller_service_principal_id
}

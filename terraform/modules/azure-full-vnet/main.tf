resource "azurerm_resource_group" "vnet_rg" {
  count    = var.use_existing_rg ? 0 : 1
  name     = var.base_name
  location = var.location
  tags     = var.tags
}

data "azurerm_resource_group" "vnet_rg" {
  count = var.use_existing_rg ? 1 : 0
  name  = var.base_name
}

locals {
  rg_name   = var.use_existing_rg ? data.azurerm_resource_group.vnet_rg[0].name : azurerm_resource_group.vnet_rg[0].name
  vnet_name = length(var.custom_vnet_name) > 0 ? var.custom_vnet_name : "${var.base_name}-vnet"
}

resource "azurerm_virtual_network" "vnet" {
  name                = local.vnet_name
  location            = var.location
  resource_group_name = local.rg_name
  address_space       = var.vnet_address_space
  tags                = var.tags
}

resource "azurerm_subnet" "vnet_subnets" {
  for_each = {
    for index, subnet in var.subnets : subnet.name => subnet
  }
  name                                          = each.key
  resource_group_name                           = local.rg_name
  virtual_network_name                          = azurerm_virtual_network.vnet.name
  address_prefixes                              = each.value.address_prefixes
  service_endpoints                             = each.value.service_endpoints
  private_link_service_network_policies_enabled = try(each.value.private_link_service_network_policies_enabled, true)
  private_endpoint_network_policies             = try(each.value.private_endpoint_network_policies, "Enabled")

  dynamic "delegation" {
    for_each = each.value.delegations
    content {
      name = delegation.key

      dynamic "service_delegation" {
        for_each = delegation.value.service_delegations
        content {
          name    = service_delegation.value.name
          actions = service_delegation.value.actions
        }
      }
    }
  }
}

# var.peered_vnets
resource "azurerm_virtual_network_peering" "vnet_peering" {
  for_each                     = var.peered_vnets
  name                         = "${azurerm_virtual_network.vnet.name}-to-${each.key}"
  resource_group_name          = local.rg_name
  virtual_network_name         = azurerm_virtual_network.vnet.name
  remote_virtual_network_id    = each.value
  allow_virtual_network_access = true
  allow_forwarded_traffic      = false
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

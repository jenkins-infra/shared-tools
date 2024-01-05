####################################################################################
## NAT gateway to allow outbound connection on a centralized and scalable appliance
####################################################################################
data "azurerm_resource_group" "outbound" {
  name = var.resource_group_name
}
resource "azurerm_public_ip" "outbound" {
  name                = var.name
  location            = data.azurerm_resource_group.outbound.location
  resource_group_name = data.azurerm_resource_group.outbound.name
  allocation_method   = "Static"
  sku                 = "Standard"
}
resource "azurerm_nat_gateway" "outbound" {
  name                = var.name
  location            = data.azurerm_resource_group.outbound.location
  resource_group_name = data.azurerm_resource_group.outbound.name
  sku_name            = "Standard"
}
resource "azurerm_nat_gateway_public_ip_association" "outbound" {
  nat_gateway_id       = azurerm_nat_gateway.outbound.id
  public_ip_address_id = azurerm_public_ip.outbound.id
}
resource "azurerm_subnet_nat_gateway_association" "outbound" {
  for_each       = toset(var.subnet_ids)
  subnet_id      = each.key
  nat_gateway_id = azurerm_nat_gateway.outbound.id
}

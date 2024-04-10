output "public_ip_list" {
  value = var.outbound_ip_count == 1 ? azurerm_public_ip.outbound.ip_address : join(",", concat([azurerm_public_ip.outbound.ip_address], azurerm_public_ip.additional_outbounds.*.ip_address))
}

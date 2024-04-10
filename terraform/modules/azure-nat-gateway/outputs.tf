output "public_ip" {
  value = var.amount_outbound_ips == 1 ? azurerm_public_ip.outbound.ip_address : join(",", concat([azurerm_public_ip.outbound.ip_address], azurerm_public_ip.additional_outbounds.*.ip_address))
}

output "service_fqdn" {
  value = var.service_fqdn
}

output "storage_service_principal_id" {
  value = azuread_service_principal.controller.id
}

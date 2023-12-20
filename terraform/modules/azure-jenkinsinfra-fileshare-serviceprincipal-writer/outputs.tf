output "service_fqdn" {
  value = var.service_fqdn
}

output "fileshare_serviceprincipal_writer_id" {
  value = azuread_service_principal.fileshare_serviceprincipal_writer.id
}

output "service_fqdn" {
  value = var.service_fqdn
}

# TODO: to be removed, see https://github.com/jenkins-infra/helpdesk/issues/4149
output "fileshare_serviceprincipal_writer_id" {
  value = azuread_service_principal.fileshare_serviceprincipal_writer.id
}

# TODO: to be removed & replaced by fileshare_serviceprincipal_writer_application_client_password, see https://github.com/jenkins-infra/helpdesk/issues/4149
output "fileshare_serviceprincipal_writer_password" {
  sensitive = true
  value     = azuread_application_password.fileshare_serviceprincipal_writer.value
}

output "fileshare_serviceprincipal_writer_application_client_id" {
  value = azuread_application.fileshare_serviceprincipal_writer.client_id
}

output "fileshare_serviceprincipal_writer_application_client_password" {
  sensitive = true
  value     = azuread_application_password.fileshare_serviceprincipal_writer.value
}

# TODO: to be removed, see https://github.com/jenkins-infra/helpdesk/issues/4149
output "fileshare_serviceprincipal_writer_sp_id" {
  value = azuread_service_principal.fileshare_serviceprincipal_writer.id
}

# TODO: to be removed, see https://github.com/jenkins-infra/helpdesk/issues/4149
output "fileshare_serviceprincipal_writer_sp_password" {
  sensitive = true
  value     = azuread_service_principal_password.fileshare_serviceprincipal_writer.value
}

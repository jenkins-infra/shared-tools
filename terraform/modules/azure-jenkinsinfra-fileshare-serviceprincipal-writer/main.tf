####################################################################################
## Azure Active Directory Resources to allow manipulating file shares
####################################################################################
resource "azuread_application" "fileshare_serviceprincipal_writer" {
  display_name = var.service_fqdn
  owners       = var.active_directory_owners
  tags         = [for key, value in var.default_tags : "${key}:${value}"]
  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000" # Microsoft Graph

    resource_access {
      id   = "e1fe6dd8-ba31-4d61-89e7-88639da4683d" # User.Read
      type = "Scope"
    }
  }
  web {
    homepage_url = var.active_directory_url
  }
}
resource "azuread_service_principal" "fileshare_serviceprincipal_writer" {
  client_id                    = azuread_application.storage.client_id
  app_role_assignment_required = false
  owners                       = var.active_directory_owners
}
resource "azuread_application_password" "fileshare_serviceprincipal_writer" {
  application_id = azuread_application.storage.id
  display_name   = "${var.service_fqdn}-tf-managed"
  end_date       = var.service_principal_end_date
}
# https://learn.microsoft.com/en-us/azure/storage/common/storage-use-azcopy-authorize-azure-active-directory#verify-role-assignments
resource "azurerm_role_assignment" "file_share_privileged_contributor" {
  scope                = var.file_share_id
  role_definition_name = "Storage File Data Privileged Contributor"
  principal_id         = azuread_service_principal.storage.id
}

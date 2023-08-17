locals {
  service_stripped_name = replace(var.service_fqdn, ".", "-")
  controller_fqdn       = "controller.${var.service_fqdn}"
}

locals {
  service_short_name          = trimprefix(trimprefix(var.service_fqdn, var.dns_zone), ".")
  service_short_stripped_name = replace(local.service_short_name, ".", "-")
  service_stripped_name       = replace(var.service_fqdn, ".", "-")
  controller_fqdn             = "controller.${var.service_fqdn}"
}

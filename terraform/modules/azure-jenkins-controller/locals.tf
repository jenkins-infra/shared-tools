locals {
  service_fqdn    = "${var.controller_short_hostname}.${var.controller_base_domain}"
  controller_fqdn = "controller.${local.service_fqdn}"
  controller_name = replace(local.service_fqdn, ".", "-")
}

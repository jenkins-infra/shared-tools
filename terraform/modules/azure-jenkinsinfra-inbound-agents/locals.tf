locals {
  stripped_short_service_name = replace(replace(var.service_fqdn, ".", "-"), "jenkinsio", "jio")
}

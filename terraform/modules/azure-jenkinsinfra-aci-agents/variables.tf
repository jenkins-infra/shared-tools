variable "service_short_stripped_name" {
  type = string
}

variable "aci_agents_resource_group_name" {
  type = string
}

variable "controller_service_principal_id" {
  type = string
}

variable "custom_role_id" {
  type    = string
  default = ""
}

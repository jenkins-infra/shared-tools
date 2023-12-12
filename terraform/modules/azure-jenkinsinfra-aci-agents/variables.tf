variable "role_name" {
  type        = string
  description = "Must be unique"
}

variable "aci_agents_resource_group_name" {
  type = string
}

variable "controller_service_principal_id" {
  type = string
}

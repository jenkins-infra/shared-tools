variable "service_fqdn" {
  type = string
}

variable "aci_agents_resource_group_name" {
  type = string
}

variable "controller_service_principal_id" {
  type = string
}

variable "aci_agents_network_name" {
  type = string
}

variable "aci_agents_network_rg_name" {
  type = string
}

variable "aci_agents_subnet_name" {
  type = string
}

# Required for NSG (can't be on the vnet RGs neither on agent RGs both for permissions reasons)
variable "controller_rg_name" {
  type = string
}

variable "controller_ips" {
  type = list(string)
}

variable "service_short_stripped_name" {
  type = string
}

variable "default_tags" {
  type    = map(string)
  default = {}
}

variable "jenkins_infra_ips" {
  type = object({
    privatevpn_subnet = list(string)
    acp_service_ips   = list(string)
  })
}

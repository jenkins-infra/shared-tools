# Required variables
variable "service_fqdn" {
  type = string
}

variable "service_short_stripped_name" {
  type = string
}

variable "ephemeral_agents_network_name" {
  type = string
}

variable "ephemeral_agents_network_rg_name" {
  type = string
}

# Required for NSG (can't be on the vnet RGs neither on agent RGs both for permissions reasons)
variable "controller_rg_name" {
  type = string
}

variable "ephemeral_agents_subnet_name" {
  type = string
}

variable "controller_ips" {
  type = list(string)
}

variable "controller_service_principal_id" {
  type = string
}

variable "default_tags" {
  type    = map(string)
  default = {}
}

variable "jenkins_infra_ips" {
  type = object({
    # ldap_ipv4           = string
    # puppet_ipv4         = string
    gpg_keyserver_ipv4s = list(string)
    privatevpn_subnet   = list(string)
  })
}

variable "custom_resourcegroup_name" {
  type    = string
  default = ""
}

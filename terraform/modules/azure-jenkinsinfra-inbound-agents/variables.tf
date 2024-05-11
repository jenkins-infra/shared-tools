# Required variables
variable "service_fqdn" {
  type        = string
  description = "FQDN of the Jenkins service requiring the inbound agents"
}
variable "controller_rg_name" {
  type        = string
  description = "Name of the controller Resource Group (where NSG will be located)"
}
variable "controller_ips" {
  type        = list(string)
  description = "List of IP(v4)s of the controller to allow agent inbound connections"
}
variable "inbound_agents_network_rg_name" {
  type        = string
  description = "Name of the Resource Group hosting the inbound agents subnet's virtual network"
}
variable "inbound_agents_network_name" {
  type        = string
  description = "Name of the Virtual Network hosting the inbound agents subnet"
}
variable "inbound_agents_subnet_name" {
  type        = string
  description = "Name of the Subnet hosting the inbound agents"
}
variable "default_tags" {
  type    = map(string)
  default = {}
}

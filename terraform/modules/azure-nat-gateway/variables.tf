variable "name" {
  type        = string
  description = "Name of the NAT gateway (and associated Public IP)"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the Resource Group to use"
}

variable "vnet_name" {
  type        = string
  description = "Name of the Virtual Network to use"
}

variable "subnet_names" {
  type        = list(string)
  description = "List of subnets (names) to associate with this gateway"
}

variable "amount_outbound_ips" {
  type        = number
  description = "Amount of additional outbound Ips to use."
  default     = 1
}

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

variable "outbound_ip_count" {
  type        = number
  description = "Number of outbound IPs to use."
  default     = 1
}

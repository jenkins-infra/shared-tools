variable "name" {
  type        = string
  description = "Name of the NAT gateway (and associated Public IP)"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet (names) to associate with this gateway"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the Resource Group in which to create NAT gateways and its resources"
}

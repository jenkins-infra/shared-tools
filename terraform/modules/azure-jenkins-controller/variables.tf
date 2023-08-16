# Required variables
variable "controller_short_hostname" {
  type = string
}

variable "admin_username" {
  type = string
}

variable "admin_ssh_publickey" {
  type = string
}

variable "location" {
  type = string
}

variable "dns_zone_name" {
  type = string
}

variable "dns_resourcegroup_name" {
  type = string
}

variable "controller_subnet_id" {
  type = string
}

variable "controller_data_disk_size_gb" {
  type = string
}

variable "controller_vm_size" {
  type = string
}

# Optionals variables
variable "is_public" {
  type    = bool
  default = false
}

variable "controller_base_domain" {
  type    = string
  default = "jenkins.io"
}

variable "default_tags" {
  type    = map(string)
  default = {}
}

variable "controller_data_disk_type" {
  type    = string
  default = "StandardSSD_LRS"
}

variable "controller_os_disk_size_gb" {
  type    = number
  default = 32 # Minimal size for Ubuntu 22.04 official image
}

variable "controller_os_disk_type" {
  type    = string
  default = "StandardSSD_LRS"
}

## TODO: backward compatibility variables to be removed (implies renaming resources)
variable "controller_resourcegroup_name" {
  type    = string
  default = ""
}

variable "controller_vm_name" {
  type    = string
  default = ""
}

variable "controller_datadisk_name" {
  type    = string
  default = ""
}

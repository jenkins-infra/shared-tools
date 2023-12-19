# Required variables
variable "service_fqdn" {
  type = string
}

variable "storage_service_principal_ids" {
  type = list(string)
}

variable "storage_service_principal_end_date" {
  type = string
}

variable "storage_file_share_ids" {
  type    = list(string)
  default = []
}

# Optional variables
variable "default_tags" {
  type    = map(string)
  default = {}
}

variable "storage_active_directory_url" {
  type    = string
  default = ""
}

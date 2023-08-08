variable "cluster_name" {
  type = string
}

variable "cluster_ca_certificate_b64" {
  type = string
}

variable "cluster_hostname" {
  type = string
}

variable "svcaccount_admin_name" {
  type    = string
  default = "infraciadmin"
}

variable "svcaccount_admin_namespace" {
  type    = string
  default = "kube-system"
}

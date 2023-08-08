terraform {
  required_providers {
    kubernetes = {
    }
  }
}

resource "kubernetes_service_account_v1" "infraciadmin" {
  metadata {
    name      = var.svcaccount_admin_name
    namespace = var.svcaccount_admin_namespace
  }
  automount_service_account_token = "false"
}
resource "kubernetes_secret_v1" "infraciadmin_token" {
  metadata {
    name      = "${var.svcaccount_admin_name}-token"
    namespace = var.svcaccount_admin_namespace
    annotations = {
      "kubernetes.io/service-account.name" = "${var.svcaccount_admin_name}"
    }
  }
  type = "kubernetes.io/service-account-token"
}
resource "kubernetes_cluster_role_binding" "infraciadmin_clusteradmin" {
  metadata {
    name = "${var.svcaccount_admin_name}_clusteradmin"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "ServiceAccount"
    name      = var.svcaccount_admin_name
    namespace = var.svcaccount_admin_namespace
  }
}

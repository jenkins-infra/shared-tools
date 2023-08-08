output "kubeconfig" {
  sensitive = true
  value     = <<-EOF
  apiVersion: v1
  kind: Config
  clusters:
    - name: ${var.cluster_name}
      cluster:
        certificate-authority-data: ${var.cluster_ca_certificate_b64}
        server: ${var.cluster_hostname}
  contexts:
    - name: ${var.svcaccount_admin_name}@${var.cluster_name}
      context:
        cluster: ${var.cluster_name}
        namespace: ${var.svcaccount_admin_namespace}
        user: ${var.svcaccount_admin_name}
  users:
    - name: ${var.svcaccount_admin_name}
      user:
        token: ${lookup(kubernetes_secret_v1.infraciadmin_token.data, "token")}
  current-context: ${var.svcaccount_admin_name}@${var.cluster_name}
  EOF
}

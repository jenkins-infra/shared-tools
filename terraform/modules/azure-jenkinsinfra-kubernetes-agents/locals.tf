locals {
  short_stripped_service_name   = replace(replace(var.service_fqdn, ".", "-"), "jenkinsio", "jio")
  short_stripped_nsg_agent_name = "${local.short_stripped_service_name}-kube-agents-${data.azurerm_subnet.kubernetes_agents.name}"
}

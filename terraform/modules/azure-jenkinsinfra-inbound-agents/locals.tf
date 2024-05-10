locals {
  stripped_short_service_name   = replace(replace(var.service_fqdn, ".", "-"), "jenkinsio", "jio")
  stripped_short_nsg_agent_name = "${local.stripped_short_service_name}-kube-agents-${data.azurerm_subnet.kubernetes_agents.name}"
}

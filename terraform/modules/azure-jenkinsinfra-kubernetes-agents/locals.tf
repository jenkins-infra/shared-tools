locals {
  service_short_stripped_name   = replace(replace(var.service_fqdn, ".", "-"), "jenkinsio", "jio")
  nsg_agent_short_stripped_name = "${local.service_short_stripped_name}-kube-agents-${data.azurerm_subnet.kubernetes_agents.name}"
}

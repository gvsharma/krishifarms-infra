locals {
  name_prefix          = "${var.project}-${var.environment}"
  api_fqdn             = var.enable_custom_domain ? "dev.api.${var.domain_name}" : ""
  web_fqdn             = var.enable_custom_domain ? "dev.${var.domain_name}" : ""
  ssm_parameter_prefix = "/krishifarms/${var.environment}"

  # CI may pass TF_VAR_github_token="" when KRISHIFARMS_GH_TOKEN is unset (not null).
  github_token_configured = var.github_token != null && trimspace(var.github_token) != ""
}

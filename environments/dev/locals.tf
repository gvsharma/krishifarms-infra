locals {
  name_prefix          = "${var.project}-${var.environment}"
  api_fqdn             = var.enable_custom_domain ? "dev.api.${var.domain_name}" : ""
  web_fqdn             = var.enable_custom_domain ? "dev.${var.domain_name}" : ""
  ssm_parameter_prefix = "/krishifarms/${var.environment}"

  # Ternary short-circuits (unlike &&): skip trimspace when token is null.
  github_token_configured = var.github_token != null ? trimspace(var.github_token) != "" : false
}

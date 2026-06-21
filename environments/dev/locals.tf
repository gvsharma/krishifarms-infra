locals {
  name_prefix          = "${var.project}-${var.environment}"
  api_fqdn             = var.enable_custom_domain ? "dev.api.${var.domain_name}" : ""
  web_fqdn             = var.enable_custom_domain ? "dev.${var.domain_name}" : ""
  ssm_parameter_prefix = "/krishifarms/${var.environment}"
}

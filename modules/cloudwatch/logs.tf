locals {
  log_groups = {
    nginx_access = "/krishifarms/${var.environment}/nginx/access"
    nginx_error  = "/krishifarms/${var.environment}/nginx/error"
    api          = "/krishifarms/${var.environment}/api"
    docker       = "/krishifarms/${var.environment}/docker"
    backup       = "/krishifarms/${var.environment}/backup"
    bootstrap    = "/krishifarms/${var.environment}/bootstrap"
  }
}

resource "aws_cloudwatch_log_group" "this" {
  for_each = local.log_groups

  name              = each.value
  retention_in_days = var.log_retention_days

  tags = {
    Name        = each.key
    Environment = var.environment
  }
}

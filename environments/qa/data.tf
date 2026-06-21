data "aws_caller_identity" "current" {}

data "aws_instance" "app" {
  instance_id = var.existing_ec2_instance_id
}

data "aws_route53_zone" "root" {
  count = var.enable_custom_domain ? 1 : 0
  name  = var.domain_name
}

output "name_prefix" {
  value = local.name_prefix
}

output "ec2_instance_id" {
  value = data.aws_instance.app.id
}

output "ec2_public_ip" {
  value = var.existing_ec2_public_ip
}

output "ec2_instance_profile_name" {
  value = module.iam.ec2_instance_profile_name
}

output "documents_bucket_name" {
  value = module.s3.documents_bucket_name
}

output "backups_bucket_name" {
  value = module.s3.backups_bucket_name
}

output "frontend_bucket_name" {
  value = module.s3.frontend_bucket_name
}

output "deploy_bucket_name" {
  value = module.s3.deploy_bucket_name
}

output "ec2_security_group_id" {
  value = module.security_groups.ec2_security_group_id
}

output "api_url" {
  value = var.enable_custom_domain ? "https://${local.api_fqdn}" : "http://${var.existing_ec2_public_ip}"
}

output "route53_name_servers" {
  value = var.enable_custom_domain ? module.route53[0].name_servers : []
}

output "acm_certificate_arn" {
  value = var.enable_custom_domain ? module.acm[0].certificate_arn_validated : null
}

output "terraform_ci_role_arn" {
  value = module.iam.terraform_ci_role_arn
}

output "backend_deploy_role_arn" {
  value = module.iam.backend_deploy_role_arn
}

output "cloudwatch_log_groups" {
  value = module.cloudwatch.log_group_names
}

output "cloudwatch_dashboard" {
  value = module.cloudwatch.dashboard_name
}

output "ssm_parameter_prefix" {
  value = local.ssm_parameter_prefix
}

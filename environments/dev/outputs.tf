output "environment" {
  value = var.environment
}

output "aws_region" {
  value = var.aws_region
}

output "aws_account_id" {
  value = var.aws_account_id
}

output "name_prefix" {
  value = local.name_prefix
}

output "api_url" {
  value = var.enable_custom_domain ? "https://${local.api_fqdn}" : "http://${var.existing_ec2_public_ip}"
}

output "health_url" {
  value = var.health_check_url
}

output "ec2_instance_id" {
  value = var.existing_ec2_instance_id
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

output "deploy_bucket_name" {
  value = module.s3.deploy_bucket_name
}

output "backend_deploy_enabled" {
  value = var.enable_backend_ssm_deploy
}

output "backend_deploy_bucket" {
  value = try(module.backend_deploy_artifacts[0].bucket_name, null)
}

output "backend_deploy_role_arn" {
  value = try(module.ci_backend_deploy[0].deploy_role_arn, null)
}

output "backend_deploy_github_setup" {
  description = "GitHub repository variables/secrets for krishifarms-backend deploy workflow."
  value = var.enable_backend_ssm_deploy ? {
    secret_AWS_BACKEND_DEPLOY_ROLE_ARN = module.ci_backend_deploy[0].deploy_role_arn
    variable_DEPLOY_BUCKET             = module.backend_deploy_artifacts[0].bucket_name
    variable_EC2_INSTANCE_ID           = var.existing_ec2_instance_id
    variable_EC2_HOST                  = var.existing_ec2_public_ip
    variable_AWS_REGION                = var.aws_region
    variable_HEALTH_CHECK_URL          = var.health_check_url
    variable_NGINX_LOCAL_PORT          = tostring(var.nginx_local_port)
    terraform_managed_github_config    = length(module.github_backend_deploy_config) > 0
  } : null
}

output "terraform_ci_role_arn" {
  value       = "arn:aws:iam::${var.aws_account_id}:role/KrishiFarmsGitHubTerraformRole"
  description = "Created by bootstrap/ — not managed in dev stack."
}

output "shared_ec2_note" {
  value = "Dev uses the same EC2 as Gamya (port ${var.nginx_local_port}). Prod KrishiFarms uses 8081."
}

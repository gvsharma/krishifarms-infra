output "api_url" {
  value = var.enable_custom_domain ? "https://${local.api_fqdn}" : "http://${var.existing_ec2_public_ip}"
}

output "ec2_instance_profile_name" {
  value = module.iam.ec2_instance_profile_name
}

output "deploy_bucket_name" {
  value = module.s3.deploy_bucket_name
}

output "backend_deploy_role_arn" {
  value = module.iam.backend_deploy_role_arn
}

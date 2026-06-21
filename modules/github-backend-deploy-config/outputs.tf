output "repository" {
  description = "Configured GitHub repository."
  value       = var.repository
}

output "managed_variables" {
  description = "GitHub Actions variables managed by this module."
  value       = ["DEPLOY_BUCKET", "EC2_INSTANCE_ID", "EC2_HOST"]
}

output "managed_secrets" {
  description = "GitHub Actions secrets managed by this module."
  value       = ["AWS_BACKEND_DEPLOY_ROLE_ARN"]
}

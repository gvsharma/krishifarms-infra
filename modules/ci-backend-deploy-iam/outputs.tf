output "deploy_role_arn" {
  description = "IAM role ARN for GitHub Actions backend deploy (aws-actions/configure-aws-credentials)."
  value       = aws_iam_role.github_backend_deploy.arn
}

output "deploy_role_name" {
  description = "IAM role name for GitHub Actions backend deploy."
  value       = aws_iam_role.github_backend_deploy.name
}

output "oidc_provider_arn" {
  description = "GitHub OIDC provider ARN used for trust."
  value       = local.oidc_provider_arn
}

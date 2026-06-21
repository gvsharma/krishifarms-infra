output "role_arn" {
  description = "IAM role ARN — set as GitHub secret AWS_ROLE_ARN."
  value       = aws_iam_role.terraform.arn
}

output "role_name" {
  description = "IAM role name."
  value       = aws_iam_role.terraform.name
}

output "oidc_provider_arn" {
  description = "GitHub OIDC provider ARN."
  value       = local.oidc_provider_arn
}

output "aws_account_id" {
  description = "AWS account ID where resources were created."
  value       = data.aws_caller_identity.current.account_id
}

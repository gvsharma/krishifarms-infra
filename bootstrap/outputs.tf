output "state_bucket_name" {
  value       = aws_s3_bucket.terraform_state.id
  description = "Terraform remote state S3 bucket."
}

output "state_bucket_arn" {
  value       = aws_s3_bucket.terraform_state.arn
  description = "Terraform remote state S3 bucket ARN."
}

output "lock_table_name" {
  value       = aws_dynamodb_table.terraform_locks.name
  description = "DynamoDB table for state locking."
}

output "lock_table_arn" {
  value       = aws_dynamodb_table.terraform_locks.arn
  description = "DynamoDB lock table ARN."
}

output "terraform_state_iam_policy_arn" {
  value       = try(aws_iam_policy.terraform_state_access[0].arn, null)
  description = "Least-privilege IAM policy for Terraform state access."
}

output "github_terraform_role_arn" {
  description = "IAM role ARN — set as GitHub variable/secret AWS_ROLE_ARN."
  value       = try(module.github_terraform[0].role_arn, null)
}

output "github_terraform_role_name" {
  description = "IAM role name for GitHub Actions Terraform."
  value       = try(module.github_terraform[0].role_name, null)
}

output "backend_config_dev" {
  description = "Remote backend settings for environments/dev."
  value = {
    bucket         = aws_s3_bucket.terraform_state.id
    key            = "infra/dev/terraform.tfstate"
    region         = var.aws_region
    encrypt        = true
    dynamodb_table = aws_dynamodb_table.terraform_locks.name
  }
}

output "backend_config_prod" {
  description = "Remote backend settings for environments/prod."
  value = {
    bucket         = aws_s3_bucket.terraform_state.id
    key            = "infra/prod/terraform.tfstate"
    region         = var.aws_region
    encrypt        = true
    dynamodb_table = aws_dynamodb_table.terraform_locks.name
  }
}

output "aws_region" {
  value = var.aws_region
}

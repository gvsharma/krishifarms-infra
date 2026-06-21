output "state_bucket_name" {
  value       = aws_s3_bucket.terraform_state.id
  description = "Terraform remote state S3 bucket."
}

output "lock_table_name" {
  value       = aws_dynamodb_table.terraform_locks.name
  description = "DynamoDB table for state locking."
}

output "aws_region" {
  value = var.aws_region
}

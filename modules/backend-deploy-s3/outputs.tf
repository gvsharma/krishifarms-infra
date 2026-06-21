output "bucket_name" {
  description = "S3 bucket for GitHub Actions JAR uploads."
  value       = aws_s3_bucket.deploy.bucket
}

output "bucket_arn" {
  description = "S3 bucket ARN."
  value       = aws_s3_bucket.deploy.arn
}

output "deploy_object_key" {
  description = "S3 object key used for the current deploy JAR."
  value       = "incoming/krishifarms-deploy.env"
}

output "ec2_read_policy_arn" {
  description = "IAM policy ARN — attach to EC2 role for S3 JAR download."
  value       = aws_iam_policy.ec2_read.arn
}

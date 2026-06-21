variable "aws_region" {
  type        = string
  description = "AWS region for state resources."
  default     = "ap-south-1"
}

variable "state_bucket_name" {
  type        = string
  description = "S3 bucket name for Terraform remote state."
  default     = "krishifarms-terraform-state"
}

variable "lock_table_name" {
  type        = string
  description = "DynamoDB table name for state locking."
  default     = "terraform-locks"
}

variable "project" {
  type    = string
  default = "krishifarms"
}

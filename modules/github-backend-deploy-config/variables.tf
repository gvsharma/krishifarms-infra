variable "repository" {
  type        = string
  description = "Target GitHub repository (org/repo)."
}

variable "deploy_role_arn" {
  type        = string
  description = "IAM role ARN for GitHub Actions OIDC backend deploy."
}

variable "deploy_bucket" {
  type        = string
  description = "S3 bucket for deploy artifacts."
}

variable "ec2_instance_id" {
  type        = string
  description = "EC2 instance ID for SSM deploy."
}

variable "ec2_host" {
  type        = string
  description = "EC2 public IP or hostname for health checks (Elastic IP when provisioned)."
}

variable "name_prefix" {
  type        = string
  description = "Prefix for IAM role and policy names."
}

variable "github_repository" {
  type        = string
  description = "GitHub repository allowed to assume the role (org/repo format)."
}

variable "deploy_bucket_arn" {
  type        = string
  description = "S3 bucket ARN for backend JAR uploads."
}

variable "ec2_instance_arn" {
  type        = string
  description = "Target EC2 instance ARN for SSM SendCommand."
}

variable "create_oidc_provider" {
  type        = bool
  description = "Create the GitHub OIDC provider (set false if it already exists in the account)."
  default     = false
}

variable "github_oidc_thumbprint" {
  type        = string
  description = "GitHub Actions OIDC thumbprint."
  default     = "6938fd4d98bab03fa91895be9a8269eb296c0d62"
}

variable "allowed_ref_subjects" {
  type        = list(string)
  description = "GitHub OIDC sub claim patterns (e.g. repo:org/repo:ref:refs/heads/main)."
  default     = []
}

variable "rds_instance_arn" {
  type        = string
  description = "RDS instance ARN for deploy-time start/describe (optional)."
  default     = null
}

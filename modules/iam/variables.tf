variable "name_prefix" {
  type = string
}

variable "environment" {
  type = string
}

variable "documents_bucket_arn" {
  type = string
}

variable "backups_bucket_arn" {
  type = string
}

variable "deploy_bucket_arn" {
  type        = string
  default     = ""
  description = "Deploy artifacts bucket ARN (optional)."
}

variable "frontend_bucket_arn" {
  type        = string
  default     = ""
  description = "Frontend bucket ARN for CI deploy role."
}

variable "ssm_parameter_prefix" {
  type        = string
  description = "SSM path prefix for app secrets, e.g. /krishifarms/prod."
}

variable "github_repository" {
  type        = string
  default     = ""
  description = "GitHub repo for OIDC trust (owner/name)."
}

variable "github_backend_repository" {
  type        = string
  default     = ""
  description = "Backend app repo for deploy OIDC."
}

variable "ec2_instance_arn" {
  type        = string
  default     = ""
  description = "Existing EC2 ARN for SSM deploy scoping."
}

variable "create_github_oidc_provider" {
  type    = bool
  default = false
}

variable "cloudwatch_log_group_arns" {
  type        = list(string)
  default     = []
  description = "Log group ARNs the EC2 role may write to."
}

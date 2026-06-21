variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

variable "aws_account_id" {
  type        = string
  description = "AWS account ID (same as Gamya Couture)."
  default     = "085863558134"
}

variable "project" {
  type    = string
  default = "krishifarms"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "owner" {
  type    = string
  default = "Venkat"
}

variable "domain_name" {
  type = string
}

variable "existing_ec2_instance_id" {
  type        = string
  description = "Shared Gamya EC2 instance ID (same host as prod)."
}

variable "existing_ec2_public_ip" {
  type        = string
  description = "Elastic IP of the shared EC2."
}

variable "vpc_id" {
  type = string
}

variable "github_infra_repository" {
  type    = string
  default = "gvsharma/krishifarms-infra"
}

variable "github_backend_repository" {
  type    = string
  default = "gvsharma/krishifarms-crm"
}

variable "github_token" {
  type        = string
  description = "GitHub PAT with repo scope on github_backend_repository for Terraform-managed Actions config. Null or empty skips github_backend_deploy_config."
  sensitive   = true
  default     = null
}

variable "create_github_oidc_provider" {
  type    = bool
  default = false
}

variable "enable_backend_ssm_deploy" {
  type        = bool
  description = "Provision S3 deploy bucket + GitHub OIDC role for backend CI."
  default     = true
}

variable "enable_custom_domain" {
  type    = bool
  default = true
}

variable "log_retention_days" {
  type    = number
  default = 3
}

variable "force_destroy_buckets" {
  type    = bool
  default = true
}

variable "nginx_local_port" {
  type        = number
  description = "Docker nginx bind port on shared EC2 (8081 prod, 8082 dev)."
  default     = 8082
}

variable "health_check_url" {
  type        = string
  description = "Local health URL for deploy verification."
  default     = "http://127.0.0.1:8082/health"
}

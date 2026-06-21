variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

variable "project" {
  type    = string
  default = "krishifarms"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "domain_name" {
  type = string
}

variable "existing_ec2_instance_id" {
  type        = string
  description = "Dev EC2 instance ID (existing or manually created)."
}

variable "existing_ec2_public_ip" {
  type = string
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

variable "create_github_oidc_provider" {
  type    = bool
  default = false
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

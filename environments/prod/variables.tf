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
  default = "prod"
}

variable "domain_name" {
  type        = string
  description = "Root domain, e.g. krishifarms.in"
}

variable "existing_ec2_instance_id" {
  type        = string
  description = "Existing EC2 instance ID to reuse (required)."
}

variable "existing_ec2_public_ip" {
  type        = string
  description = "Elastic IP of existing EC2 for Route53 A record."
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where existing EC2 lives."
}

variable "enable_ssh" {
  type    = bool
  default = false
}

variable "admin_cidr" {
  type    = string
  default = "0.0.0.0/0"
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
  default = 14
}

variable "alarm_notification_arn" {
  type    = string
  default = ""
}

variable "force_destroy_buckets" {
  type    = bool
  default = false
}

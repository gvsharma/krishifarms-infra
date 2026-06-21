module "github_terraform" {
  source = "../modules/ci-terraform-iam"

  aws_account_id              = var.aws_account_id
  github_repository           = var.github_repository
  role_name                   = var.role_name
  create_oidc_provider        = var.create_oidc_provider
  attach_administrator_access = var.attach_administrator_access

  oidc_subjects = [
    "repo:${var.github_repository}:*",
  ]

  tags = {
    Project     = "krishifarms"
    ManagedBy   = "terraform"
    Environment = "bootstrap"
    Purpose     = "github-actions-terraform-dev"
  }
}

variable "aws_account_id" {
  type    = string
  default = "085863558134"
}

variable "github_repository" {
  type    = string
  default = "gvsharma/krishifarms-infra"
}

variable "role_name" {
  type    = string
  default = "KrishiFarmsGitHubTerraformRole"
}

variable "create_oidc_provider" {
  type    = bool
  default = false
}

variable "attach_administrator_access" {
  type    = bool
  default = true
}

provider "aws" {
  region = "ap-south-1"
}

output "terraform_ci_role_arn" {
  value = module.github_terraform.role_arn
}

output "oidc_provider_arn" {
  value = module.github_terraform.oidc_provider_arn
}

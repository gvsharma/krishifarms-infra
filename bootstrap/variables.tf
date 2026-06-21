variable "aws_region" {
  type        = string
  description = "AWS region for state resources."
  default     = "ap-south-1"
}

variable "project" {
  type    = string
  default = "krishifarms"
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

variable "terraform_state_iam_policy_name" {
  type        = string
  description = "Name of the IAM policy granting least-privilege state access."
  default     = "krishifarms-terraform-state-access"
}

variable "enable_iam_policy" {
  type        = bool
  description = "Create a reusable IAM policy for Terraform operators."
  default     = true
}

variable "aws_account_id" {
  type        = string
  description = "Expected AWS account ID (same as Gamya Couture)."
  default     = "085863558134"
}

variable "enable_github_actions" {
  type        = bool
  description = "Create IAM role for GitHub Actions Terraform plan/apply via OIDC."
  default     = true
}

variable "github_repository" {
  type        = string
  description = "GitHub repo for infra workflows (org/repo)."
  default     = "gvsharma/krishifarms-infra"

  validation {
    condition     = !var.enable_github_actions || can(regex("^[^/]+/[^/]+$", var.github_repository))
    error_message = "github_repository must be org/repo format."
  }
}

variable "github_terraform_role_name" {
  type        = string
  description = "IAM role name for GitHub Actions Terraform (dev)."
  default     = "KrishiFarmsGitHubTerraformRole"
}

variable "create_github_oidc_provider" {
  type        = bool
  description = "Create GitHub OIDC provider (false if Gamya bootstrap already created it)."
  default     = false
}

variable "github_attach_administrator_access" {
  type        = bool
  description = "Attach AdministratorAccess to GitHub Terraform role."
  default     = true
}

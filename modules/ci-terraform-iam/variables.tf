variable "aws_account_id" {
  type        = string
  description = "Expected AWS account ID (safety check on apply)."
  default     = "085863558134"
}

variable "github_repository" {
  type        = string
  description = "GitHub repository in org/repo format."
  default     = "gvsharma/krishifarms-infra"
}

variable "role_name" {
  type        = string
  description = "IAM role name for GitHub Actions Terraform (dev)."
  default     = "KrishiFarmsGitHubTerraformRole"
}

variable "create_oidc_provider" {
  type        = bool
  description = "Create the GitHub OIDC provider (set false if it already exists in the account)."
  default     = true
}

variable "github_oidc_thumbprint" {
  type        = string
  description = "GitHub Actions OIDC TLS thumbprint."
  default     = "6938fd4d98bab03fa91895be9a8269eb296c0d62"
}

variable "oidc_subjects" {
  type        = list(string)
  description = "GitHub OIDC sub claim patterns allowed to assume the role."
  default     = ["repo:gvsharma/krishifarms-infra:*"]
}

variable "attach_administrator_access" {
  type        = bool
  description = "Attach AWS managed AdministratorAccess policy (broad — tighten for production later)."
  default     = true
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to the IAM role."
  default = {
    Project     = "krishifarms"
    ManagedBy   = "terraform"
    Environment = "dev"
    Purpose     = "github-actions-terraform-dev"
  }
}

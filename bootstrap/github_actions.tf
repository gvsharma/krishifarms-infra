module "github_terraform" {
  count  = var.enable_github_actions ? 1 : 0
  source = "../modules/ci-terraform-iam"

  aws_account_id              = var.aws_account_id
  github_repository           = var.github_repository
  role_name                   = var.github_terraform_role_name
  create_oidc_provider        = var.create_github_oidc_provider
  attach_administrator_access = var.github_attach_administrator_access

  oidc_subjects = [
    "repo:${var.github_repository}:*",
  ]

  tags = {
    Project     = var.project
    ManagedBy   = "terraform"
    Environment = "bootstrap"
    Purpose     = "github-actions-terraform-dev"
  }
}

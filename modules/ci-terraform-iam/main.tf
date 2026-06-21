data "aws_caller_identity" "current" {}

locals {
  github_oidc_url = "https://token.actions.githubusercontent.com"
  oidc_audience   = replace(local.github_oidc_url, "https://", "")
}

check "expected_aws_account" {
  assert {
    condition     = data.aws_caller_identity.current.account_id == var.aws_account_id
    error_message = "Applied to account ${data.aws_caller_identity.current.account_id}, expected ${var.aws_account_id}."
  }
}

# ------------------------------------------------------------------------------
# GitHub Actions OIDC identity provider
# https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services
# ------------------------------------------------------------------------------

resource "aws_iam_openid_connect_provider" "github" {
  count = var.create_oidc_provider ? 1 : 0

  url             = local.github_oidc_url
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [var.github_oidc_thumbprint]

  tags = var.tags
}

data "aws_iam_openid_connect_provider" "github" {
  count = var.create_oidc_provider ? 0 : 1

  url = local.github_oidc_url
}

locals {
  oidc_provider_arn = var.create_oidc_provider ? aws_iam_openid_connect_provider.github[0].arn : data.aws_iam_openid_connect_provider.github[0].arn
}

# ------------------------------------------------------------------------------
# IAM role trust policy — repo:gvsharma/gamya-couture-infra:*
# ------------------------------------------------------------------------------

data "aws_iam_policy_document" "github_assume_role" {
  statement {
    sid    = "GitHubActionsOIDC"
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = [local.oidc_provider_arn]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_audience}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "${local.oidc_audience}:sub"
      values   = var.oidc_subjects
    }
  }
}

resource "aws_iam_role" "terraform" {
  name               = var.role_name
  assume_role_policy = data.aws_iam_policy_document.github_assume_role.json

  tags = merge(var.tags, {
    Name = var.role_name
  })
}

# ------------------------------------------------------------------------------
# Permissions — AdministratorAccess for now (replace with scoped policy later)
# ------------------------------------------------------------------------------

resource "aws_iam_role_policy_attachment" "administrator_access" {
  count = var.attach_administrator_access ? 1 : 0

  role       = aws_iam_role.terraform.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

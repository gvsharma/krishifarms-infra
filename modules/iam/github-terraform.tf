data "aws_iam_policy_document" "github_oidc_assume" {
  count = var.github_repository != "" ? 1 : 0

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [local.github_oidc_provider_arn]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.github_repository}:*"]
    }
  }
}

data "aws_iam_policy_document" "terraform_ci" {
  count = var.github_repository != "" ? 1 : 0

  statement {
    sid    = "TerraformState"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListBucket",
      "s3:DeleteObject",
    ]
    resources = [
      "arn:aws:s3:::krishifarms-terraform-state",
      "arn:aws:s3:::krishifarms-terraform-state/*",
    ]
  }

  statement {
    sid    = "TerraformLock"
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem",
    ]
    resources = ["arn:aws:dynamodb:*:${data.aws_caller_identity.current.account_id}:table/terraform-locks"]
  }

  statement {
    sid       = "ManageInfra"
    effect    = "Allow"
    actions   = ["*"]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "aws:RequestedRegion"
      values   = ["ap-south-1", "us-east-1"]
    }
  }
}

resource "aws_iam_openid_connect_provider" "github" {
  count = var.create_github_oidc_provider ? 1 : 0

  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03fa02154a50987747b006a2daa"]
}

locals {
  github_oidc_provider_arn = var.create_github_oidc_provider ? aws_iam_openid_connect_provider.github[0].arn : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
}

resource "aws_iam_role" "terraform_ci" {
  count = var.github_repository != "" ? 1 : 0

  name_prefix        = "${var.name_prefix}-tf-ci-"
  assume_role_policy = data.aws_iam_policy_document.github_oidc_assume[0].json

  tags = {
    Name = "${var.name_prefix}-terraform-ci"
  }
}

resource "aws_iam_role_policy" "terraform_ci" {
  count = var.github_repository != "" ? 1 : 0

  name_prefix = "${var.name_prefix}-tf-ci-"
  role        = aws_iam_role.terraform_ci[0].id
  policy      = data.aws_iam_policy_document.terraform_ci[0].json
}

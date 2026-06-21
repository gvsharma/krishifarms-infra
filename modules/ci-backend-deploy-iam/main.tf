data "aws_region" "current" {}

locals {
  github_oidc_url = "https://token.actions.githubusercontent.com"
  repo_subject    = "repo:${var.github_repository}:*"
  oidc_subjects   = distinct(concat([local.repo_subject], var.allowed_ref_subjects))
}

resource "aws_iam_openid_connect_provider" "github" {
  count = var.create_oidc_provider ? 1 : 0

  url             = local.github_oidc_url
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [var.github_oidc_thumbprint]
}

data "aws_iam_openid_connect_provider" "github" {
  count = var.create_oidc_provider ? 0 : 1

  url = local.github_oidc_url
}

locals {
  oidc_provider_arn = var.create_oidc_provider ? aws_iam_openid_connect_provider.github[0].arn : data.aws_iam_openid_connect_provider.github[0].arn
}

data "aws_iam_policy_document" "github_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = [local.oidc_provider_arn]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "${replace(local.github_oidc_url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "${replace(local.github_oidc_url, "https://", "")}:sub"
      values   = local.oidc_subjects
    }
  }
}

resource "aws_iam_role" "github_backend_deploy" {
  name_prefix        = "${var.name_prefix}-gh-be-deploy-"
  assume_role_policy = data.aws_iam_policy_document.github_assume_role.json

  tags = {
    Name            = "${var.name_prefix}-github-backend-deploy"
    ResourcePurpose = "iam-github-backend-deploy"
  }
}

data "aws_iam_policy_document" "deploy" {
  statement {
    sid    = "UploadDeployJar"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject",
    ]
    resources = [
      var.deploy_bucket_arn,
      "${var.deploy_bucket_arn}/incoming/*",
    ]
  }

  statement {
    sid    = "RunDeployOnInstance"
    effect = "Allow"
    actions = [
      "ssm:SendCommand",
    ]
    resources = [
      var.ec2_instance_arn,
      "arn:aws:ssm:${data.aws_region.current.name}::document/AWS-RunShellScript",
    ]
  }

  statement {
    sid    = "ReadDeployCommandResult"
    effect = "Allow"
    actions = [
      "ssm:GetCommandInvocation",
      "ssm:ListCommandInvocations",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "PreflightDeployTarget"
    effect = "Allow"
    actions = [
      "ssm:DescribeInstanceInformation",
      "ec2:DescribeInstances",
      "ec2:DescribeInstanceStatus",
    ]
    resources = ["*"]
  }


  dynamic "statement" {
    for_each = var.rds_instance_arn != null ? [1] : []
    content {
      sid    = "PrepareRdsForDeploy"
      effect = "Allow"
      actions = [
        "rds:DescribeDBInstances",
        "rds:StartDBInstance",
      ]
      resources = [var.rds_instance_arn]
    }
  }

  dynamic "statement" {
    for_each = var.rds_instance_arn != null ? [1] : []
    content {
      sid    = "ResolveRdsByTag"
      effect = "Allow"
      actions = [
        "tag:GetResources",
      ]
      resources = ["*"]
    }
  }

  statement {
    sid    = "StartDeployTargetIfStopped"
    effect = "Allow"
    actions = [
      "ec2:StartInstances",
    ]
    resources = [var.ec2_instance_arn]
  }
}

resource "aws_iam_role_policy" "deploy" {
  name_prefix = "${var.name_prefix}-gh-be-deploy-"
  role        = aws_iam_role.github_backend_deploy.id
  policy      = data.aws_iam_policy_document.deploy.json
}

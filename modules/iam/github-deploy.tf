data "aws_iam_policy_document" "backend_deploy_assume" {
  count = var.github_backend_repository != "" ? 1 : 0

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
      values   = ["repo:${var.github_backend_repository}:*"]
    }
  }
}

data "aws_iam_policy_document" "backend_deploy" {
  count = var.github_backend_repository != "" ? 1 : 0

  statement {
    sid    = "UploadDeployArtifacts"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:ListBucket",
    ]
    resources = compact([
      var.deploy_bucket_arn,
      var.deploy_bucket_arn != "" ? "${var.deploy_bucket_arn}/*" : "",
    ])
  }

  dynamic "statement" {
    for_each = var.ec2_instance_arn != "" ? [1] : []
    content {
      sid    = "SSMDeployToEC2"
      effect = "Allow"
      actions = [
        "ssm:SendCommand",
        "ssm:GetCommandInvocation",
        "ssm:ListCommandInvocations",
        "ssm:DescribeInstanceInformation",
      ]
      resources = ["*"]
      condition {
        test     = "StringEquals"
        variable = "ssm:resourceTag/Project"
        values   = ["krishifarms"]
      }
    }
  }

  dynamic "statement" {
    for_each = var.ec2_instance_arn != "" ? [1] : []
    content {
      sid       = "SSMOnTargetInstance"
      effect    = "Allow"
      actions   = ["ssm:SendCommand"]
      resources = [var.ec2_instance_arn]
    }
  }
}

resource "aws_iam_role" "backend_deploy" {
  count = var.github_backend_repository != "" ? 1 : 0

  name_prefix        = "${var.name_prefix}-backend-deploy-"
  assume_role_policy = data.aws_iam_policy_document.backend_deploy_assume[0].json

  tags = {
    Name = "${var.name_prefix}-backend-deploy"
  }
}

resource "aws_iam_role_policy" "backend_deploy" {
  count = var.github_backend_repository != "" ? 1 : 0

  name_prefix = "${var.name_prefix}-backend-deploy-"
  role        = aws_iam_role.backend_deploy[0].id
  policy      = data.aws_iam_policy_document.backend_deploy[0].json
}

locals {
  # Short-circuit before comparing bucket ARN — unknown until apply breaks count on Terraform 1.9.x
  create_frontend_github_deploy = var.github_backend_repository != "" ? (var.frontend_bucket_arn != "" ? 1 : 0) : 0
}

data "aws_iam_policy_document" "frontend_deploy" {
  count = local.create_frontend_github_deploy

  statement {
    sid    = "SyncFrontend"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket",
      "s3:GetObject",
    ]
    resources = [
      var.frontend_bucket_arn,
      "${var.frontend_bucket_arn}/*",
    ]
  }
}

resource "aws_iam_role" "frontend_deploy" {
  count = local.create_frontend_github_deploy

  name_prefix        = "${var.name_prefix}-frontend-deploy-"
  assume_role_policy = data.aws_iam_policy_document.backend_deploy_assume[0].json

  tags = {
    Name = "${var.name_prefix}-frontend-deploy"
  }
}

resource "aws_iam_role_policy" "frontend_deploy" {
  count = local.create_frontend_github_deploy

  name_prefix = "${var.name_prefix}-frontend-deploy-"
  role        = aws_iam_role.frontend_deploy[0].id
  policy      = data.aws_iam_policy_document.frontend_deploy[0].json
}

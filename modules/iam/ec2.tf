data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "ec2_s3" {
  statement {
    sid    = "DocumentsReadWrite"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket",
    ]
    resources = [
      var.documents_bucket_arn,
      "${var.documents_bucket_arn}/*",
    ]
  }

  statement {
    sid    = "BackupsWrite"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:ListBucket",
    ]
    resources = [
      var.backups_bucket_arn,
      "${var.backups_bucket_arn}/*",
    ]
  }

  dynamic "statement" {
    for_each = var.deploy_bucket_arn != "" ? [1] : []
    content {
      sid    = "DeployArtifactsRead"
      effect = "Allow"
      actions = [
        "s3:GetObject",
        "s3:ListBucket",
      ]
      resources = [
        var.deploy_bucket_arn,
        "${var.deploy_bucket_arn}/*",
      ]
    }
  }
}

data "aws_iam_policy_document" "ec2_ssm" {
  statement {
    sid    = "ReadAppParameters"
    effect = "Allow"
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:GetParametersByPath",
    ]
    resources = [
      "arn:aws:ssm:*:${data.aws_caller_identity.current.account_id}:parameter${var.ssm_parameter_prefix}/*",
    ]
  }
}

data "aws_iam_policy_document" "ec2_cloudwatch_logs" {
  statement {
    sid    = "WriteLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams",
    ]
    resources = length(var.cloudwatch_log_group_arns) > 0 ? [
      for arn in var.cloudwatch_log_group_arns : "${arn}:*"
    ] : ["arn:aws:logs:*:*:log-group:/krishifarms/*"]
  }
}

resource "aws_iam_role" "ec2" {
  name_prefix        = "${var.name_prefix}-ec2-"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = {
    Name = "${var.name_prefix}-ec2-role"
  }
}

resource "aws_iam_role_policy" "ec2_s3" {
  name_prefix = "${var.name_prefix}-ec2-s3-"
  role        = aws_iam_role.ec2.id
  policy      = data.aws_iam_policy_document.ec2_s3.json
}

resource "aws_iam_role_policy" "ec2_ssm" {
  name_prefix = "${var.name_prefix}-ec2-ssm-"
  role        = aws_iam_role.ec2.id
  policy      = data.aws_iam_policy_document.ec2_ssm.json
}

resource "aws_iam_role_policy" "ec2_cloudwatch_logs" {
  name_prefix = "${var.name_prefix}-ec2-cw-"
  role        = aws_iam_role.ec2.id
  policy      = data.aws_iam_policy_document.ec2_cloudwatch_logs.json
}

resource "aws_iam_role_policy_attachment" "ec2_ssm_core" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ec2_cloudwatch_agent" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "ec2" {
  name_prefix = "${var.name_prefix}-ec2-"
  role        = aws_iam_role.ec2.name

  tags = {
    Name = "${var.name_prefix}-ec2-profile"
  }
}

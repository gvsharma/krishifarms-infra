data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

locals {
  bucket_name = "${var.name_prefix}-backend-deploy"
}

resource "aws_s3_bucket" "deploy" {
  bucket        = local.bucket_name
  force_destroy = var.force_destroy

  tags = {
    Name            = local.bucket_name
    ResourcePurpose = "backend-deploy-artifacts"
  }
}

resource "aws_s3_bucket_public_access_block" "deploy" {
  bucket = aws_s3_bucket.deploy.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "deploy" {
  bucket = aws_s3_bucket.deploy.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "deploy" {
  bucket = aws_s3_bucket.deploy.id

  rule {
    id     = "expire-old-jars"
    status = "Enabled"

    filter {
      prefix = "incoming/"
    }

    expiration {
      days = var.artifact_retention_days
    }
  }
}

data "aws_iam_policy_document" "ec2_read" {
  statement {
    sid    = "ListDeployPrefix"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
    ]
    resources = [aws_s3_bucket.deploy.arn]
    condition {
      test     = "StringLike"
      variable = "s3:prefix"
      values   = ["incoming/*"]
    }
  }

  statement {
    sid    = "GetDeployJar"
    effect = "Allow"
    actions = [
      "s3:GetObject",
    ]
    resources = ["${aws_s3_bucket.deploy.arn}/incoming/*"]
  }
}

resource "aws_iam_policy" "ec2_read" {
  name_prefix = "${var.name_prefix}-backend-deploy-read-"
  description = "Allow EC2 to download backend deploy JARs from S3."
  policy      = data.aws_iam_policy_document.ec2_read.json

  tags = {
    Name            = "${var.name_prefix}-backend-deploy-read"
    ResourcePurpose = "iam-backend-deploy-s3-read"
  }
}

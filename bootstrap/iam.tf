data "aws_iam_policy_document" "terraform_state_access" {
  statement {
    sid    = "ListStateBucket"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
    ]
    resources = [
      aws_s3_bucket.terraform_state.arn,
    ]
  }

  statement {
    sid    = "ReadWriteStateObjects"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]
    resources = [
      "${aws_s3_bucket.terraform_state.arn}/*",
    ]
  }

  statement {
    sid    = "ManageStateLocks"
    effect = "Allow"
    actions = [
      "dynamodb:DescribeTable",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem",
    ]
    resources = [
      aws_dynamodb_table.terraform_locks.arn,
    ]
  }
}

resource "aws_iam_policy" "terraform_state_access" {
  count = var.enable_iam_policy ? 1 : 0

  name        = var.terraform_state_iam_policy_name
  description = "Least-privilege access to KrishiFarms Terraform remote state (S3 + DynamoDB lock)."
  policy      = data.aws_iam_policy_document.terraform_state_access.json
}

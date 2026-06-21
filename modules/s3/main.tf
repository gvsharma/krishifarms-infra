resource "aws_s3_bucket" "documents" {
  bucket        = local.documents_bucket_name
  force_destroy = var.force_destroy_buckets

  tags = {
    Name = "${var.name_prefix}-documents"
    Role = "documents"
  }
}

resource "aws_s3_bucket" "backups" {
  bucket        = local.backups_bucket_name
  force_destroy = var.force_destroy_buckets

  tags = {
    Name = "${var.name_prefix}-backups"
    Role = "postgres-backups"
  }
}

resource "aws_s3_bucket" "frontend" {
  bucket        = local.frontend_bucket_name
  force_destroy = var.force_destroy_buckets

  tags = {
    Name = "${var.name_prefix}-frontend"
    Role = "react-static"
  }
}

resource "aws_s3_bucket" "deploy" {
  bucket        = local.deploy_bucket_name
  force_destroy = var.force_destroy_buckets

  tags = {
    Name = "${var.name_prefix}-deploy-artifacts"
    Role = "ci-deploy"
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  for_each = {
    documents = aws_s3_bucket.documents.id
    backups   = aws_s3_bucket.backups.id
    frontend  = aws_s3_bucket.frontend.id
    deploy    = aws_s3_bucket.deploy.id
  }

  bucket = each.value

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  for_each = {
    documents = aws_s3_bucket.documents.id
    backups   = aws_s3_bucket.backups.id
    frontend  = aws_s3_bucket.frontend.id
    deploy    = aws_s3_bucket.deploy.id
  }

  bucket = each.value

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "this" {
  for_each = {
    documents = aws_s3_bucket.documents.id
    backups   = aws_s3_bucket.backups.id
    frontend  = aws_s3_bucket.frontend.id
    deploy    = aws_s3_bucket.deploy.id
  }

  bucket = each.value

  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_ownership_controls" "this" {
  for_each = {
    documents = aws_s3_bucket.documents.id
    backups   = aws_s3_bucket.backups.id
    frontend  = aws_s3_bucket.frontend.id
    deploy    = aws_s3_bucket.deploy.id
  }

  bucket = each.value

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "backups" {
  bucket = aws_s3_bucket.backups.id

  rule {
    id     = "expire-old-backups"
    status = "Enabled"
    filter {
      prefix = "postgres/"
    }
    expiration {
      days = var.backup_retention_days
    }
    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }

  depends_on = [aws_s3_bucket_versioning.this]
}

resource "aws_s3_bucket_lifecycle_configuration" "documents" {
  bucket = aws_s3_bucket.documents.id

  rule {
    id     = "transition-to-ia"
    status = "Enabled"
    filter {
      prefix = ""
    }
    transition {
      days          = var.documents_ia_transition_days
      storage_class = "STANDARD_IA"
    }
  }

  depends_on = [aws_s3_bucket_versioning.this]
}

resource "aws_s3_bucket_lifecycle_configuration" "deploy" {
  bucket = aws_s3_bucket.deploy.id

  rule {
    id     = "expire-deploy-artifacts"
    status = "Enabled"
    filter {
      prefix = "releases/"
    }
    expiration {
      days = 14
    }
  }

  depends_on = [aws_s3_bucket_versioning.this]
}

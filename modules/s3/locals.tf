locals {
  documents_bucket_name = "${var.name_prefix}-documents-${var.account_id}"
  backups_bucket_name   = "${var.name_prefix}-backups-${var.account_id}"
  frontend_bucket_name  = "${var.name_prefix}-frontend-${var.account_id}"
  deploy_bucket_name    = "${var.name_prefix}-deploy-${var.account_id}"
}

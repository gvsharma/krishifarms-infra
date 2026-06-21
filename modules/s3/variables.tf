variable "name_prefix" {
  type        = string
  description = "Resource name prefix, e.g. krishifarms-prod."
}

variable "account_id" {
  type        = string
  description = "AWS account ID for globally unique bucket suffix."
}

variable "force_destroy_buckets" {
  type        = bool
  description = "Allow bucket deletion with objects (non-prod only)."
  default     = false
}

variable "enable_versioning" {
  type        = bool
  description = "Enable S3 versioning on data buckets."
  default     = true
}

variable "backup_retention_days" {
  type        = number
  description = "Days before backup objects expire."
  default     = 90
}

variable "documents_ia_transition_days" {
  type        = number
  description = "Days before documents transition to STANDARD_IA."
  default     = 90
}

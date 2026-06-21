variable "name_prefix" {
  type        = string
  description = "Prefix for bucket and IAM policy names."
}

variable "force_destroy" {
  type        = bool
  description = "Allow bucket deletion when non-empty (dev only)."
  default     = true
}

variable "artifact_retention_days" {
  type        = number
  description = "Expire deploy JAR objects after this many days."
  default     = 30
}

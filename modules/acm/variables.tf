variable "domain_name" {
  type = string
}

variable "subject_alternative_names" {
  type        = list(string)
  default     = []
  description = "Additional hostnames on the certificate."
}

variable "route53_zone_id" {
  type        = string
  description = "Route53 zone for DNS validation."
}

variable "wait_for_validation" {
  type    = bool
  default = true
}

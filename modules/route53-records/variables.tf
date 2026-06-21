variable "zone_id" {
  type = string
}

variable "domain_name" {
  type = string
}

variable "api_fqdn" {
  type        = string
  description = "API hostname, e.g. api.krishifarms.in"
}

variable "web_fqdn" {
  type        = string
  description = "Web portal hostname."
  default     = ""
}

variable "ec2_public_ip" {
  type        = string
  description = "Existing EC2 Elastic IP for API A record."
}

variable "create_web_record" {
  type    = bool
  default = false
}

variable "web_target" {
  type        = string
  description = "Optional CNAME/alias target for web (CloudFront domain)."
  default     = ""
}

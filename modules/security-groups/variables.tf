variable "name_prefix" {
  type = string
}

variable "vpc_id" {
  type        = string
  description = "VPC where the existing EC2 instance lives."
}

variable "admin_cidr" {
  type        = string
  description = "Admin IP for optional SSH access."
  default     = "0.0.0.0/0"
}

variable "enable_ssh" {
  type    = bool
  default = false
}

variable "web_ingress_cidr_blocks" {
  type        = list(string)
  description = "CIDR blocks allowed to reach HTTP/HTTPS."
  default     = ["0.0.0.0/0"]
}

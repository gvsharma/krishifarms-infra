variable "name_prefix" {
  type = string
}

variable "environment" {
  type = string
}

variable "log_retention_days" {
  type    = number
  default = 7
}

variable "ec2_instance_id" {
  type        = string
  description = "Existing EC2 instance ID for metric alarms."
}

variable "alarm_notification_arn" {
  type        = string
  default     = ""
  description = "Optional SNS topic ARN for alarm actions."
}

variable "disk_path" {
  type    = string
  default = "/"
}

variable "cpu_threshold" {
  type    = number
  default = 85
}

variable "disk_threshold" {
  type    = number
  default = 80
}

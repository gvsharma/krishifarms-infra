variable "project" {
  type        = string
  description = "Project name for cost allocation."
  default     = "krishifarms"
}

variable "environment" {
  type        = string
  description = "Deployment environment (dev, qa, prod)."
}

variable "owner" {
  type        = string
  description = "Individual or team responsible for the stack."
  default     = "Venkat"
}

variable "cost_optimization" {
  type        = string
  description = "Whether cost controls are active."
  default     = "enabled"
}

variable "auto_shutdown" {
  type        = string
  description = "Whether auto stop/start scheduling is enabled."
  default     = "false"
}

locals {
  common_tags = {
    Project          = var.project
    Environment      = var.environment
    ManagedBy        = "terraform"
    Owner            = var.owner
    CostOptimization = var.cost_optimization
    AutoShutdown     = var.auto_shutdown
  }
}

output "common_tags" {
  description = "Default tags applied via provider default_tags."
  value       = local.common_tags
}

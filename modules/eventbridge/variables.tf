# Project Configuration
variable "project_name" {
  description = "Name of the project - used for resource naming and tagging"
  type        = string
  default     = "yemoja"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "sns_topic_arn" {
  description = "ARN of sns topic"
  type        = string
}


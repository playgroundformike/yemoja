# sns/variables.tf

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


variable "queue_arns" {
  description = "ARNs of the main SQS queues"
  type        = map(string)
}

variable "queue_urls" {
  description = "IDs of the main SQS queues"
  type        = map(string)
}


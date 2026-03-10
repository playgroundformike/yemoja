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

variable "delay_seconds" {
  type    = number
  default = 0
}
variable "max_message_size" {
  type    = number
  default = 262144

}
variable "message_retention_seconds" {
  type    = number
  default = 86400

}
variable "receive_wait_time_seconds" {
  type    = number
  default = 10
}
variable "visibility_timeout_seconds" {
  type    = number
  default = 30
}

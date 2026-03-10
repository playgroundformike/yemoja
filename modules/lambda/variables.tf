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

variable "function_name" {
  description = "function_name - (Required) Unique name for your Lambda Function."
  type        = string
}

variable "handler" {
  description = "handler - (Optional) Function entrypoint in your code."
  type        = string
  default     = "app.lambda_handler"
}

variable "runtime" {
  description = "runtime - (Optional) Identifier of the function's runtime. Required if package_type is Zip. See Runtimes for valid values."
  type        = string
  default     = "python3.12"
}

variable "env_variables" {
  description = "env_variables - (Optional) Map of environment variables available to your Lambda function during execution. "
  type        = map(string)
  default     = {}
}

variable "source_file" {
  description = "source_file (String) Package this file into the archive. One and only one of source, source_content_filename (with source_content), source_file, or source_dir must be specified."

  type = string
}

variable "output_path" {
  description = "output_path (String) The output of the archive file."
  type        = string
}

variable "type" {
  description = "type (String) The type of archive to generate. NOTE: zip and tar.gz is supported."
  type        = string
  default     = "zip"
}


variable "timeout" {
  description = "longer timeout for processing"
  type        = number
  default     = 10
}
variable "mem_size" {
  description = "memory for file processing"
  type        = number
  default     = 512
}

variable "event_source_arn" {
  description = "event_source_arn - (Optional) Event source ARN - required for Kinesis stream, DynamoDB stream, SQS queue, MQ broker, MSK cluster or DocumentDB change stream. Incompatible with Self Managed Kafka source."

  type = string
}

variable "custom_policy_actions" {
  description = "List of IAM actions for custom policy"
  type        = list(string)
  default     = []
}

variable "custom_policy_resources" {
  description = "List of resource ARNs for custom policy"
  type        = list(string)
  default     = []
}

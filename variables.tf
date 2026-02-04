variable "function_name" {
  type        = string
  description = "Lambda function name"
}

variable "runtime" {
  type        = string
  description = "Lambda runtime"

  validation {
    condition     = contains(["nodejs20.x", "nodejs18.x", "nodejs16.x", "python3.12", "python3.11", "python3.10", "python3.9", "java21", "java17", "go1.x", "dotnet8", "dotnet6", "ruby3.2", "provided.al2", "provided.al2023"], var.runtime)
    error_message = "runtime must be a supported Lambda runtime string."
  }
}

variable "handler" {
  type        = string
  description = "Lambda handler"
}

variable "role_arn" {
  type        = string
  description = "IAM role ARN for Lambda"
}

variable "memory_size" {
  type        = number
  description = "Lambda memory size"
  default     = 128
}

variable "timeout" {
  type        = number
  description = "Lambda timeout"
  default     = 3
}

variable "lambda_type" {
  type        = string
  description = "Lambda type"
  default     = "NON_VPC"

  validation {
    condition     = contains(["VPC", "NON_VPC"], var.lambda_type)
    error_message = "lambda_type must be one of VPC or NON_VPC."
  }
}

variable "vpc_config_enabled" {
  type        = bool
  description = "Whether VPC config is enabled"
  default     = false
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnet IDs for VPC config"
  default     = []
}

variable "security_group_ids" {
  type        = list(string)
  description = "Security group IDs for VPC config"
  default     = []
}

variable "environment" {
  type        = map(string)
  description = "Environment variables"
  default     = {}
}

variable "filename" {
  type        = string
  description = "Lambda deployment package filename"
  default     = null
}

variable "s3_bucket" {
  type        = string
  description = "S3 bucket for deployment package"
  default     = null
}

variable "s3_key" {
  type        = string
  description = "S3 key for deployment package"
  default     = null
}

variable "s3_object_version" {
  type        = string
  description = "S3 object version for deployment package"
  default     = null
}

variable "source_code_hash" {
  type        = string
  description = "Base64-encoded SHA256 of deployment package"
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to Lambda"
  default     = {}
}

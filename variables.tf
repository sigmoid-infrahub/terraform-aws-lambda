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
  default     = null

  validation {
    condition     = var.create_iam_role || var.role_arn != null
    error_message = "Either create_iam_role must be true or role_arn must be provided."
  }
}

variable "create_iam_role" {
  type        = bool
  description = "Whether to create IAM role for Lambda"
  default     = false
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

variable "create_security_group" {
  type        = bool
  description = "Whether to create security group for Lambda"
  default     = false
}

variable "vpc_id" {
  type        = string
  description = "VPC ID for Lambda security group"
  default     = null
}

variable "security_group_ingress_cidr_blocks" {
  type        = list(string)
  description = "Ingress CIDR blocks for Lambda security group"
  default     = ["10.0.0.0/8"]
}

variable "create_log_group" {
  type        = bool
  description = "Whether to create CloudWatch log group for Lambda"
  default     = false
}

variable "log_group_retention_in_days" {
  type        = number
  description = "CloudWatch log group retention in days"
  default     = 14
}

variable "log_group_kms_key_id" {
  type        = string
  description = "KMS key ID or ARN used to encrypt CloudWatch logs. When empty, provider default encryption is used."
  default     = ""
}

variable "reserved_concurrent_executions" {
  type        = number
  description = "Reserved concurrent executions for Lambda. Use -1 to leave concurrency unreserved."
  default     = -1

  validation {
    condition     = var.reserved_concurrent_executions == -1 || var.reserved_concurrent_executions >= 0
    error_message = "reserved_concurrent_executions must be -1 or greater than or equal to 0."
  }
}

variable "tracing_mode" {
  type        = string
  description = "Lambda X-Ray tracing mode."
  default     = "Active"

  validation {
    condition     = contains(["Active", "PassThrough"], var.tracing_mode)
    error_message = "tracing_mode must be Active or PassThrough."
  }
}

variable "dead_letter_target_arn" {
  type        = string
  description = "SNS topic or SQS queue ARN for Lambda dead letter delivery. When empty, dead letter config is disabled."
  default     = ""
}

variable "code_signing_config_arn" {
  type        = string
  description = "Lambda code signing config ARN. When empty, code signing is not enforced by this module."
  default     = ""
}

variable "architectures" {
  type        = list(string)
  description = "Instruction set architectures for Lambda. AWS allows exactly one value: arm64 or x86_64."
  default     = ["arm64"]

  validation {
    condition     = length(var.architectures) == 1 && alltrue([for architecture in var.architectures : contains(["arm64", "x86_64"], architecture)])
    error_message = "architectures must contain exactly one value: arm64 or x86_64."
  }
}

variable "ephemeral_storage_size" {
  type        = number
  description = "Lambda ephemeral storage size in MB."
  default     = 512

  validation {
    condition     = var.ephemeral_storage_size >= 512 && var.ephemeral_storage_size <= 10240
    error_message = "ephemeral_storage_size must be between 512 and 10240 MB."
  }
}

variable "kms_key_arn" {
  type        = string
  description = "KMS key ARN used to encrypt Lambda environment variables. When empty, AWS-managed encryption is used."
  default     = ""
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

# ====================================
# Sigmoid Tags Configuration
# ====================================

variable "sigmoid_environment" {
  description = "Sigmoid environment identifier for cost allocation"
  type        = string
  default     = ""
}

variable "sigmoid_project" {
  description = "Sigmoid project identifier for cost allocation"
  type        = string
  default     = ""
}

variable "sigmoid_team" {
  description = "Sigmoid team identifier for cost allocation"
  type        = string
  default     = ""
}

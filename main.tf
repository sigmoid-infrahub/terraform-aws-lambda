resource "aws_lambda_function" "this" {
  function_name = var.function_name
  runtime       = var.runtime
  handler       = var.handler
  role          = var.role_arn

  filename          = var.filename
  s3_bucket         = var.s3_bucket
  s3_key            = var.s3_key
  s3_object_version = var.s3_object_version
  source_code_hash  = var.source_code_hash

  memory_size = var.memory_size
  timeout     = var.timeout

  dynamic "vpc_config" {
    for_each = var.vpc_config_enabled && var.lambda_type == "VPC" ? [1] : []
    content {
      subnet_ids         = var.subnet_ids
      security_group_ids = var.security_group_ids
    }
  }

  dynamic "environment" {
    for_each = length(var.environment) == 0 ? [] : [1]
    content {
      variables = var.environment
    }
  }

  tags = local.resolved_tags
}

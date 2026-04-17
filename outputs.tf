output "function_name" {
  description = "Lambda function name"
  value       = aws_lambda_function.this.function_name
}

output "invoke_arn" {
  description = "Lambda invoke ARN"
  value       = aws_lambda_function.this.invoke_arn
}

output "arn" {
  description = "Lambda ARN"
  value       = aws_lambda_function.this.arn
}

output "iam_role_arn" {
  description = "IAM role ARN used by Lambda"
  value       = local.role_arn
}

output "security_group_id" {
  description = "Created security group ID"
  value       = var.create_security_group ? aws_security_group.this[0].id : null
}

output "log_group_name" {
  description = "Created CloudWatch log group name"
  value       = var.create_log_group ? aws_cloudwatch_log_group.this[0].name : null
}

output "module" {
  description = "Full module outputs"
  value = {
    function_name     = aws_lambda_function.this.function_name
    invoke_arn        = aws_lambda_function.this.invoke_arn
    arn               = aws_lambda_function.this.arn
    iam_role_arn      = local.role_arn
    security_group_id = var.create_security_group ? aws_security_group.this[0].id : null
    log_group_name    = var.create_log_group ? aws_cloudwatch_log_group.this[0].name : null
  }
}

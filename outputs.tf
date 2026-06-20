output "function_name" {
  description = "Lambda function name"
  value       = aws_lambda_function.this.function_name
}

output "invoke_arn" {
  description = "Lambda invoke ARN"
  value       = aws_lambda_function.this.invoke_arn
}

output "function_arn" {
  description = "Lambda function ARN"
  value       = aws_lambda_function.this.arn
}

output "arn" {
  description = "Lambda ARN"
  value       = aws_lambda_function.this.arn
}

output "role_arn" {
  description = "Created IAM role ARN when create_iam_role is true"
  value       = var.create_iam_role ? aws_iam_role.lambda[0].arn : null
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

output "log_group_arn" {
  description = "Created CloudWatch log group ARN"
  value       = var.create_log_group ? aws_cloudwatch_log_group.this[0].arn : null
}

output "function_url" {
  description = "Lambda function URL endpoint (null when create_function_url is false)"
  value       = var.create_function_url ? aws_lambda_function_url.this[0].function_url : null
}

output "module" {
  description = "Full module outputs"
  value = {
    function_name     = aws_lambda_function.this.function_name
    function_arn      = aws_lambda_function.this.arn
    invoke_arn        = aws_lambda_function.this.invoke_arn
    arn               = aws_lambda_function.this.arn
    role_arn          = var.create_iam_role ? aws_iam_role.lambda[0].arn : null
    iam_role_arn      = local.role_arn
    security_group_id = var.create_security_group ? aws_security_group.this[0].id : null
    log_group_name    = var.create_log_group ? aws_cloudwatch_log_group.this[0].name : null
    log_group_arn     = var.create_log_group ? aws_cloudwatch_log_group.this[0].arn : null
    function_url      = var.create_function_url ? aws_lambda_function_url.this[0].function_url : null
  }
}

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

output "module" {
  description = "Full module outputs"
  value = {
    function_name = aws_lambda_function.this.function_name
    invoke_arn    = aws_lambda_function.this.invoke_arn
    arn           = aws_lambda_function.this.arn
  }
}

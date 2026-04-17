resource "aws_iam_role" "lambda" {
  count = var.create_iam_role ? 1 : 0

  name = "${var.function_name}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = local.resolved_tags
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  count = var.create_iam_role ? 1 : 0

  role       = aws_iam_role.lambda[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_vpc" {
  count = var.create_iam_role && var.lambda_type == "VPC" ? 1 : 0

  role       = aws_iam_role.lambda[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_security_group" "this" {
  count = var.create_security_group ? 1 : 0

  name        = "${var.function_name}-lambda-sg"
  description = "Security group for Lambda ${var.function_name}"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.resolved_tags
}

resource "aws_cloudwatch_log_group" "this" {
  count = var.create_log_group ? 1 : 0

  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = var.log_group_retention_in_days
  tags              = local.resolved_tags
}

resource "aws_lambda_function" "this" {
  function_name = var.function_name
  runtime       = var.runtime
  handler       = var.handler
  role          = local.role_arn

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
      security_group_ids = local.security_group_ids
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

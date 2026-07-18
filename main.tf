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

resource "aws_iam_role_policy" "lambda_inline" {
  for_each = var.create_iam_role ? { for policy in var.iam_role_inline_policies : policy.name => policy } : {}

  name   = each.value.name
  role   = aws_iam_role.lambda[0].id
  policy = each.value.policy
}

# Connected-resource access. Backend passes raw ARNs as resolved module outputs;
# the policy JSON (with s3 /* and dynamodb /index/* suffixes) is built here so no
# literal "${module...}" string ever reaches Terraform. Keep in sync with the
# identical block in terraform-aws-ecs.
locals {
  connected_access_statements = concat(
    length(var.connected_s3_bucket_arns) == 0 ? [] : [
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:PutObject"]
        Resource = [for arn in var.connected_s3_bucket_arns : "${arn}/*"]
      },
      {
        Effect   = "Allow"
        Action   = ["s3:ListBucket"]
        Resource = var.connected_s3_bucket_arns
      },
    ],
    length(var.connected_dynamodb_table_arns) == 0 ? [] : [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
        ]
        Resource = concat(
          var.connected_dynamodb_table_arns,
          [for arn in var.connected_dynamodb_table_arns : "${arn}/index/*"],
        )
      },
    ],
  )
}

resource "aws_iam_role_policy" "lambda_connected_access" {
  count = var.create_iam_role && length(local.connected_access_statements) > 0 ? 1 : 0

  name = "${var.function_name}-connected-access"
  role = aws_iam_role.lambda[0].id
  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = local.connected_access_statements
  })
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

# Ingress rules on connected data resources' security groups, sourced from this
# function's created security group. Emitted on the compute module (not the data
# module) so the data module never references the compute SG, which would form a
# data<->compute module dependency cycle. Meaningful only for VPC-attached Lambdas.
resource "aws_security_group_rule" "data_ingress" {
  for_each = {
    for rule in var.data_ingress_rules :
    "${rule.security_group_id}-${rule.from_port}-${rule.protocol}" => rule
  }

  type                     = "ingress"
  security_group_id        = each.value.security_group_id
  source_security_group_id = aws_security_group.this[0].id
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  protocol                 = each.value.protocol
  description              = each.value.description
}

resource "aws_cloudwatch_log_group" "this" {
  count = var.create_log_group ? 1 : 0

  name              = "/aws/lambda/${var.function_name}"
  kms_key_id        = local.has_log_group_kms_key ? var.log_group_kms_key_id : null
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

  architectures                  = var.architectures
  code_signing_config_arn        = local.has_code_signing_config ? var.code_signing_config_arn : null
  kms_key_arn                    = local.has_kms_key ? var.kms_key_arn : null
  reserved_concurrent_executions = local.has_reserved_concurrent_executions ? var.reserved_concurrent_executions : null

  ephemeral_storage {
    size = var.ephemeral_storage_size
  }

  tracing_config {
    mode = var.tracing_mode
  }

  dynamic "dead_letter_config" {
    for_each = local.has_dead_letter_target ? [1] : []
    content {
      target_arn = var.dead_letter_target_arn
    }
  }

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

resource "aws_lambda_function_url" "this" {
  count = var.create_function_url ? 1 : 0

  function_name      = aws_lambda_function.this.function_name
  authorization_type = var.function_url_authorization_type
}

resource "aws_lambda_permission" "alb" {
  count         = length(var.target_group_arns) > 0 ? 1 : 0
  statement_id  = "AllowALBInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "elasticloadbalancing.amazonaws.com"
}

resource "aws_lb_target_group_attachment" "this" {
  count            = length(var.target_group_arns)
  target_group_arn = var.target_group_arns[count.index]
  target_id        = aws_lambda_function.this.arn
  depends_on       = [aws_lambda_permission.alb]
}

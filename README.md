# Module: Lambda

This module creates and manages an AWS Lambda function with support for VPC configuration, environment variables, and various deployment package sources.

## Features
- Lambda function creation with customizable runtime and handler
- VPC integration (Subnets and Security Groups)
- Environment variable management
- Deployment package from local file or S3
- Memory and timeout configuration
- IAM role association

## Usage
```hcl
module "lambda" {
  source = "../../terraform-modules/terraform-aws-lambda"

  function_name = "my-function"
  runtime       = "nodejs20.x"
  handler       = "index.handler"
  role_arn      = "arn:aws:iam::123456789012:role/lambda-role"
  filename      = "function.zip"
}
```

## Inputs
| Name | Type | Default | Description |
|------|------|---------|-------------|
| `function_name` | `string` | n/a | Lambda function name |
| `runtime` | `string` | n/a | Lambda runtime |
| `handler` | `string` | n/a | Lambda handler |
| `role_arn` | `string` | n/a | IAM role ARN for Lambda |
| `memory_size` | `number` | `128` | Lambda memory size |
| `timeout` | `number` | `3` | Lambda timeout |
| `lambda_type` | `string` | `"NON_VPC"` | Lambda type |
| `vpc_config_enabled` | `bool` | `false` | Whether VPC config is enabled |
| `subnet_ids` | `list(string)` | `[]` | Subnet IDs for VPC config |
| `security_group_ids` | `list(string)` | `[]` | Security group IDs for VPC config |
| `environment` | `map(string)` | `{}` | Environment variables |
| `filename` | `string` | `null` | Lambda deployment package filename |
| `s3_bucket` | `string` | `null` | S3 bucket for deployment package |
| `s3_key` | `string` | `null` | S3 key for deployment package |
| `s3_object_version` | `string` | `null` | S3 object version for deployment package |
| `source_code_hash` | `string` | `null` | Base64-encoded SHA256 of deployment package |
| `tags` | `map(string)` | `{}` | Tags to apply to Lambda |

## Outputs
| Name | Description |
|------|-------------|
| `function_name` | Lambda function name |
| `invoke_arn` | Lambda invoke ARN |
| `arn` | Lambda ARN |
| `module` | Full module outputs |

## Environment Variables
None

## Notes
- `runtime` validation includes nodejs, python, java, go, dotnet, ruby, and provided runtimes.
- If `vpc_config_enabled` is true, `subnet_ids` and `security_group_ids` are required.
- Provide either `filename` or `s3_bucket`/`s3_key` for the deployment package.

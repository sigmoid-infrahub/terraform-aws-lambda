locals {
  sigmoid_tags = merge(
    var.sigmoid_environment != "" ? { "sigmoid:environment" = var.sigmoid_environment } : {},
    var.sigmoid_project != "" ? { "sigmoid:project" = var.sigmoid_project } : {},
    var.sigmoid_team != "" ? { "sigmoid:team" = var.sigmoid_team } : {},
  )


  resolved_tags = merge({
    ManagedBy = "sigmoid"
  }, var.tags, local.sigmoid_tags)

  role_arn                           = var.create_iam_role ? aws_iam_role.lambda[0].arn : var.role_arn
  security_group_ids                 = var.create_security_group ? [aws_security_group.this[0].id] : var.security_group_ids
  has_log_group_kms_key              = length(trimspace(var.log_group_kms_key_id)) > 0
  has_dead_letter_target             = length(trimspace(var.dead_letter_target_arn)) > 0
  has_code_signing_config            = length(trimspace(var.code_signing_config_arn)) > 0
  has_kms_key                        = length(trimspace(var.kms_key_arn)) > 0
  has_reserved_concurrent_executions = var.reserved_concurrent_executions != -1
}

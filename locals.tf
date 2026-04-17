locals {
  sigmoid_tags = merge(
    var.sigmoid_environment != "" ? { "sigmoid:environment" = var.sigmoid_environment } : {},
    var.sigmoid_project != "" ? { "sigmoid:project" = var.sigmoid_project } : {},
    var.sigmoid_team != "" ? { "sigmoid:team" = var.sigmoid_team } : {},
  )


  resolved_tags = merge({
    ManagedBy = "sigmoid"
  }, var.tags, local.sigmoid_tags)

  role_arn           = var.create_iam_role ? aws_iam_role.lambda[0].arn : var.role_arn
  security_group_ids = var.create_security_group ? [aws_security_group.this[0].id] : var.security_group_ids
}

##-----------------------------------------------------------------------------
## Locals
##-----------------------------------------------------------------------------
locals {
  name        = var.custom_name != null ? var.custom_name : module.labels.id
  label_order = var.label_order

  app_insights_id                  = coalesce(var.app_insights_id, var.application_insights_id)
  app_insights_instrumentation_key = coalesce(var.app_insights_instrumentation_key, var.application_insights_instrumentation_key)
}

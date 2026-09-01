##-----------------------------------------------------------------------------
## Locals
##-----------------------------------------------------------------------------
locals {
  name = var.custom_name != null ? var.custom_name : module.labels.id

  # Resolve Application Insights id/key: explicit override > module-created resource > null
  app_insights_id = var.application_insights_id != null ? (
    var.application_insights_id
    ) : (
    var.enable && var.application_insights_enabled ? azurerm_application_insights.main[0].id : null
  )

  app_insights_instrumentation_key = var.application_insights_id != null ? (
    var.application_insights_instrumentation_key
    ) : (
    var.enable && var.application_insights_enabled ? azurerm_application_insights.main[0].instrumentation_key : null
  )
}
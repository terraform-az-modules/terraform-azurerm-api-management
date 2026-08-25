##-----------------------------------------------------------------------------
## Locals
##-----------------------------------------------------------------------------
locals {
  name        = var.custom_name == null ? var.name : var.custom_name
  label_order = var.label_order
}

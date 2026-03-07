locals {
  tenant_id = data.azurerm_client_config.current.tenant_id

  # Diagnostic log categories for Key Vault
  diagnostic_log_categories = [
    "AuditEvent",
    "AzurePolicyEvaluationDetails",
  ]

  diagnostic_metric_categories = [
    "AllMetrics",
  ]
}

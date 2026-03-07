########################################
# Key Vault
########################################
resource "azurerm_key_vault" "this" {
  name                          = var.name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  tenant_id                     = local.tenant_id
  sku_name                      = var.sku_name
  enable_rbac_authorization     = var.enable_rbac_authorization
  purge_protection_enabled      = var.purge_protection_enabled
  soft_delete_retention_days    = var.soft_delete_retention_days
  enabled_for_deployment        = var.enabled_for_deployment
  enabled_for_disk_encryption   = var.enabled_for_disk_encryption
  enabled_for_template_deployment = var.enabled_for_template_deployment
  public_network_access_enabled = var.public_network_access_enabled

  dynamic "network_acls" {
    for_each = var.network_acls != null ? [var.network_acls] : []

    content {
      bypass                     = network_acls.value.bypass
      default_action             = network_acls.value.default_action
      ip_rules                   = network_acls.value.ip_rules
      virtual_network_subnet_ids = network_acls.value.virtual_network_subnet_ids
    }
  }

  tags = var.tags
}

########################################
# Key Vault Keys (with rotation policy)
########################################
resource "azurerm_key_vault_key" "this" {
  for_each = var.keys

  name         = each.key
  key_vault_id = azurerm_key_vault.this.id
  key_type     = each.value.key_type
  key_size     = each.value.key_size
  key_opts     = each.value.key_opts

  dynamic "rotation_policy" {
    for_each = each.value.rotation_policy != null ? [each.value.rotation_policy] : []

    content {
      dynamic "automatic" {
        for_each = rotation_policy.value.automatic != null ? [rotation_policy.value.automatic] : []

        content {
          time_before_expiry  = automatic.value.time_before_expiry
          time_after_creation = automatic.value.time_after_creation
        }
      }

      expire_after         = rotation_policy.value.expire_after
      notify_before_expiry = rotation_policy.value.notify_before_expiry
    }
  }

  tags = var.tags
}

########################################
# Key Vault Secrets
########################################
resource "azurerm_key_vault_secret" "this" {
  for_each = var.secrets

  name            = each.key
  value           = each.value.value
  key_vault_id    = azurerm_key_vault.this.id
  content_type    = each.value.content_type
  expiration_date = each.value.expiration_date

  tags = var.tags
}

########################################
# Key Vault Certificates
########################################
resource "azurerm_key_vault_certificate" "this" {
  for_each = var.certificates

  name         = each.key
  key_vault_id = azurerm_key_vault.this.id

  certificate_policy {
    issuer_parameters {
      name = each.value.issuer
    }

    key_properties {
      exportable = each.value.exportable
      key_size   = each.value.key_size
      key_type   = each.value.key_type
      reuse_key  = false
    }

    secret_properties {
      content_type = each.value.content_type
    }

    x509_certificate_properties {
      subject            = each.value.subject
      validity_in_months = each.value.validity_in_months

      subject_alternative_names {
        dns_names = each.value.dns_names
      }

      key_usage = [
        "cRLSign",
        "dataEncipherment",
        "digitalSignature",
        "keyAgreement",
        "keyCertSign",
        "keyEncipherment",
      ]
    }

    lifetime_action {
      action {
        action_type = "AutoRenew"
      }

      trigger {
        days_before_expiry = 30
      }
    }
  }

  tags = var.tags
}

########################################
# RBAC Role Assignments
########################################
resource "azurerm_role_assignment" "this" {
  for_each = var.role_assignments

  scope                = azurerm_key_vault.this.id
  role_definition_name = each.value.role_definition_name
  principal_id         = each.value.principal_id
}

########################################
# Private Endpoint
########################################
resource "azurerm_private_endpoint" "this" {
  count = var.enable_private_endpoint ? 1 : 0

  name                = "${var.name}-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "${var.name}-psc"
    private_connection_resource_id = azurerm_key_vault.this.id
    is_manual_connection           = false
    subresource_names              = ["vault"]
  }

  dynamic "private_dns_zone_group" {
    for_each = var.private_dns_zone_id != null ? [1] : []

    content {
      name                 = "default"
      private_dns_zone_ids = [var.private_dns_zone_id]
    }
  }

  tags = var.tags
}

########################################
# Diagnostic Settings
########################################
resource "azurerm_monitor_diagnostic_setting" "this" {
  count = var.enable_diagnostics ? 1 : 0

  name                       = "${var.name}-diag"
  target_resource_id         = azurerm_key_vault.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  dynamic "enabled_log" {
    for_each = local.diagnostic_log_categories

    content {
      category = enabled_log.value
    }
  }

  dynamic "metric" {
    for_each = local.diagnostic_metric_categories

    content {
      category = metric.value
    }
  }
}

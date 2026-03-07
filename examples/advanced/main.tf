provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-keyvault-advanced"
  location = "East US"
}

data "azurerm_client_config" "current" {}

module "key_vault" {
  source = "../../"

  name                = "kv-advanced-example"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  sku_name            = "premium"

  enable_rbac_authorization   = true
  purge_protection_enabled    = true
  soft_delete_retention_days  = 90
  enabled_for_disk_encryption = true

  public_network_access_enabled = true
  network_acls = {
    bypass         = "AzureServices"
    default_action = "Deny"
    ip_rules       = ["203.0.113.0/24"]
  }

  keys = {
    "encryption-key" = {
      key_type = "RSA"
      key_size = 4096
      key_opts = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]
      rotation_policy = {
        automatic = {
          time_before_expiry = "P30D"
        }
        expire_after         = "P365D"
        notify_before_expiry = "P30D"
      }
    }
    "signing-key" = {
      key_type = "RSA"
      key_size = 2048
      key_opts = ["sign", "verify"]
    }
  }

  secrets = {
    "db-connection-string" = {
      value        = "Server=myserver;Database=mydb;User=admin;Password=secret123"
      content_type = "text/plain"
    }
  }

  role_assignments = {
    "current-user-admin" = {
      principal_id         = data.azurerm_client_config.current.object_id
      role_definition_name = "Key Vault Administrator"
    }
  }

  enable_private_endpoint = false
  enable_diagnostics      = false

  tags = {
    Environment = "staging"
    ManagedBy   = "terraform"
  }
}

output "key_vault_id" {
  value = module.key_vault.key_vault_id
}

output "key_ids" {
  value = module.key_vault.key_ids
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-keyvault-complete"
  location = "East US"
}

data "azurerm_client_config" "current" {}

resource "azurerm_virtual_network" "example" {
  name                = "vnet-keyvault-complete"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "endpoint" {
  name                 = "snet-endpoint"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_private_dns_zone" "keyvault" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "keyvault" {
  name                = "keyvault-dns-link"
  private_dns_zone_id = azurerm_private_dns_zone.keyvault.id
  virtual_network_id  = azurerm_virtual_network.example.id
}

resource "azurerm_log_analytics_workspace" "example" {
  name                = "law-keyvault-complete"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

module "key_vault" {
  source = "../../"

  name                = "kv-complete-example"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  sku_name            = "premium"

  enable_rbac_authorization       = true
  purge_protection_enabled        = true
  soft_delete_retention_days      = 90
  enabled_for_deployment          = true
  enabled_for_disk_encryption     = true
  enabled_for_template_deployment = true

  public_network_access_enabled = false
  network_acls = {
    bypass         = "AzureServices"
    default_action = "Deny"
  }

  keys = {
    "hsm-encryption-key" = {
      key_type = "RSA-HSM"
      key_size = 4096
      key_opts = ["decrypt", "encrypt", "unwrapKey", "wrapKey"]
      rotation_policy = {
        automatic = {
          time_before_expiry = "P30D"
        }
        expire_after         = "P180D"
        notify_before_expiry = "P29D"
      }
    }
    "app-signing-key" = {
      key_type = "RSA"
      key_size = 2048
      key_opts = ["sign", "verify"]
    }
  }

  secrets = {
    "api-key" = {
      value           = "supersecretapikey123"
      content_type    = "text/plain"
      expiration_date = "2027-01-01T00:00:00Z"
    }
    "storage-connection" = {
      value        = "DefaultEndpointsProtocol=https;AccountName=myaccount;AccountKey=mykey"
      content_type = "text/plain"
    }
  }

  certificates = {
    "app-cert" = {
      issuer             = "Self"
      exportable         = true
      key_size           = 2048
      key_type           = "RSA"
      content_type       = "application/x-pkcs12"
      subject            = "CN=app.example.com"
      dns_names          = ["app.example.com", "www.app.example.com"]
      validity_in_months = 12
    }
  }

  role_assignments = {
    "deployer-admin" = {
      principal_id         = data.azurerm_client_config.current.object_id
      role_definition_name = "Key Vault Administrator"
    }
    "deployer-secrets" = {
      principal_id         = data.azurerm_client_config.current.object_id
      role_definition_name = "Key Vault Secrets Officer"
    }
  }

  enable_private_endpoint    = true
  private_endpoint_subnet_id = azurerm_subnet.endpoint.id
  private_dns_zone_id        = azurerm_private_dns_zone.keyvault.id

  enable_diagnostics         = true
  log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
    CostCenter  = "IT-001"
  }
}

output "key_vault_id" {
  value = module.key_vault.key_vault_id
}

output "key_vault_uri" {
  value = module.key_vault.key_vault_uri
}

output "key_ids" {
  value = module.key_vault.key_ids
}

output "certificate_ids" {
  value = module.key_vault.certificate_ids
}

output "private_endpoint_ip" {
  value = module.key_vault.private_endpoint_ip_address
}

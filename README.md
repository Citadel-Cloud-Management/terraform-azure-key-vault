# terraform-azure-key-vault

Terraform module for deploying Azure Key Vault with RBAC authorization, private endpoints, purge protection, HSM keys, certificates, and diagnostic settings.

## Features

- Azure Key Vault with configurable SKU (standard/premium)
- RBAC authorization (enabled by default)
- Purge protection and soft-delete with configurable retention
- HSM-backed and software-backed key management with automatic rotation policies
- Secret management with content types and expiration dates
- Self-signed and CA-issued certificate management
- RBAC role assignments on the Key Vault scope
- Private endpoint integration with private DNS zone support
- Diagnostic settings with Log Analytics workspace integration
- Network ACL configuration with IP rules and virtual network rules

## Usage

### Basic

```hcl
module "key_vault" {
  source = "github.com/kogunlowo123/terraform-azure-key-vault"

  name                = "kv-myapp-dev"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  enable_private_endpoint = false
  enable_diagnostics      = false

  tags = {
    Environment = "dev"
  }
}
```

### With Keys, Secrets, and Certificates

```hcl
module "key_vault" {
  source = "github.com/kogunlowo123/terraform-azure-key-vault"

  name                = "kv-myapp-prod"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  sku_name            = "premium"

  keys = {
    "encryption-key" = {
      key_type = "RSA-HSM"
      key_size = 4096
      key_opts = ["decrypt", "encrypt", "unwrapKey", "wrapKey"]
      rotation_policy = {
        automatic = {
          time_before_expiry = "P30D"
        }
        expire_after         = "P365D"
        notify_before_expiry = "P30D"
      }
    }
  }

  secrets = {
    "db-password" = {
      value        = var.db_password
      content_type = "text/plain"
    }
  }

  certificates = {
    "app-cert" = {
      subject   = "CN=app.example.com"
      dns_names = ["app.example.com"]
    }
  }

  enable_private_endpoint    = true
  private_endpoint_subnet_id = azurerm_subnet.endpoint.id
  private_dns_zone_id        = azurerm_private_dns_zone.keyvault.id

  enable_diagnostics         = true
  log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| azurerm | >= 3.80.0 |

## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| name | The name of the Key Vault | string | n/a |
| resource_group_name | The resource group name | string | n/a |
| location | The Azure region | string | n/a |
| sku_name | SKU name (standard or premium) | string | "standard" |
| enable_rbac_authorization | Enable RBAC authorization | bool | true |
| purge_protection_enabled | Enable purge protection | bool | true |
| soft_delete_retention_days | Soft-delete retention days (7-90) | number | 90 |
| enabled_for_deployment | Allow VM certificate retrieval | bool | false |
| enabled_for_disk_encryption | Allow disk encryption access | bool | false |
| enabled_for_template_deployment | Allow ARM template access | bool | false |
| public_network_access_enabled | Enable public network access | bool | false |
| network_acls | Network ACL configuration | object | null |
| keys | Map of keys to create | map(object) | {} |
| secrets | Map of secrets to create | map(object) | {} |
| certificates | Map of certificates to create | map(object) | {} |
| role_assignments | Map of role assignments | map(object) | {} |
| enable_private_endpoint | Create a private endpoint | bool | true |
| private_endpoint_subnet_id | Subnet ID for private endpoint | string | null |
| private_dns_zone_id | Private DNS zone ID | string | null |
| enable_diagnostics | Enable diagnostic settings | bool | true |
| log_analytics_workspace_id | Log Analytics workspace ID | string | null |
| tags | Tags to assign to resources | map(string) | {} |

## Outputs

| Name | Description |
|------|-------------|
| key_vault_id | The ID of the Key Vault |
| key_vault_name | The name of the Key Vault |
| key_vault_uri | The URI of the Key Vault |
| key_vault_tenant_id | The tenant ID of the Key Vault |
| key_ids | Map of key names to IDs |
| key_versions | Map of key names to versions |
| key_versionless_ids | Map of key names to versionless IDs |
| secret_ids | Map of secret names to IDs |
| secret_versionless_ids | Map of secret names to versionless IDs |
| certificate_ids | Map of certificate names to IDs |
| certificate_versionless_ids | Map of certificate names to versionless IDs |
| private_endpoint_id | Private endpoint ID |
| private_endpoint_ip_address | Private endpoint IP address |

## Examples

- [Basic](examples/basic/) - Minimal Key Vault deployment
- [Advanced](examples/advanced/) - Key Vault with keys, secrets, and RBAC
- [Complete](examples/complete/) - Full deployment with private endpoint, diagnostics, certificates, and HSM keys

## License

MIT License. See [LICENSE](LICENSE) for details.

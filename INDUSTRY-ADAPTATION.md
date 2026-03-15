# Industry Adaptation Guide

## Overview
The `terraform-azure-key-vault` module creates an Azure Key Vault with keys (including rotation policies), secrets, certificates, RBAC role assignments, private endpoints, network ACLs, diagnostic settings, purge protection, and soft delete. It serves as the centralized secrets management and cryptographic operations platform for any industry.

## Healthcare
### Compliance Requirements
- HIPAA, HITRUST, HL7 FHIR
### Configuration Changes
- Set `sku_name = "premium"` for HSM-backed keys required by HITRUST for PHI encryption.
- Set `purge_protection_enabled = true` and `soft_delete_retention_days = 90` to prevent permanent key/secret deletion (HIPAA data protection).
- Set `public_network_access_enabled = false` and `enable_private_endpoint = true` with `private_endpoint_subnet_id` to ensure secrets are only accessible from within the VNet.
- Configure `network_acls` with `default_action = "Deny"` and `bypass = "AzureServices"`.
- Create `keys` with `rotation_policy` set to auto-rotate encryption keys (e.g., `time_after_creation = "P90D"` for 90-day rotation).
- Store database connection strings and API keys as `secrets` with `expiration_date` for enforced rotation.
- Configure `role_assignments` granting "Key Vault Secrets User" to application managed identities only.
- Set `enable_diagnostics = true` with `log_analytics_workspace_id` for audit logging of all vault operations.
### Example Use Case
A health IT company stores PHI encryption keys in a premium Key Vault with HSM-backed keys, auto-rotation every 90 days, private endpoint access only, and diagnostic logs forwarded to a SIEM for HIPAA audit compliance.

## Finance
### Compliance Requirements
- SOX, PCI-DSS, SOC 2
### Configuration Changes
- Set `sku_name = "premium"` for HSM-backed keys (PCI-DSS Requirement 3.5.2).
- Set `purge_protection_enabled = true` for key non-repudiation (SOX).
- Set `public_network_access_enabled = false` with `enable_private_endpoint = true` (PCI-DSS Requirement 1).
- Configure `keys` for data encryption with `key_type = "RSA"`, `key_size = 4096`, and `rotation_policy` with auto-rotation.
- Store payment gateway credentials and TLS certificates using `secrets` and `certificates` with `expiration_date`.
- Configure `certificates` with `issuer = "DigiCert"` (or organizational CA) for PKI-issued certificates.
- Set `role_assignments` with fine-grained roles: "Key Vault Crypto Officer" for key management, "Key Vault Secrets User" for application access.
- Set `enabled_for_disk_encryption = true` if using Azure Disk Encryption for VM-based workloads.
- Enable diagnostics for SOX audit trail.
### Example Use Case
A bank manages its payment card encryption keys in a premium Key Vault with 4096-bit RSA keys, auto-rotation every 60 days, private endpoint access, and RBAC separating key administrators from application consumers.

## Government
### Compliance Requirements
- FedRAMP, CMMC, NIST 800-53
### Configuration Changes
- Deploy in Azure Government regions.
- Set `sku_name = "premium"` for FIPS 140-2 Level 2 validated HSM-backed keys (NIST SC-12, SC-13).
- Set `purge_protection_enabled = true` and `soft_delete_retention_days = 90` (NIST SC-28).
- Set `public_network_access_enabled = false` with `enable_private_endpoint = true` (NIST SC-7).
- Configure `network_acls` with `default_action = "Deny"`, `bypass = "AzureServices"`, and restricted `virtual_network_subnet_ids`.
- Create `keys` with `rotation_policy` enforcing automatic rotation per NIST key management guidelines.
- Set `enable_rbac_authorization = true` and configure `role_assignments` for separation of duties (NIST AC-5).
- Set `enable_diagnostics = true` for continuous monitoring (NIST AU-2, AU-12).
### Example Use Case
A government agency uses a premium Key Vault in Azure Government with HSM-backed keys for CUI encryption, private endpoint access, RBAC enforcing separation between key custodians and key consumers, and diagnostic logs streaming to Sentinel.

## Retail / E-Commerce
### Compliance Requirements
- PCI-DSS, CCPA/GDPR
### Configuration Changes
- Set `sku_name = "standard"` for most use cases or `"premium"` for payment card encryption keys.
- Store payment gateway API keys, TLS certificates, and database credentials as `secrets` with `expiration_date`.
- Configure `certificates` for TLS termination with auto-renewal via `lifetime_action` (auto-renew 30 days before expiry).
- Set `public_network_access_enabled = false` with `enable_private_endpoint = true` for PCI scope reduction.
- Configure `role_assignments` granting "Key Vault Secrets User" to the application's managed identity.
- Set `enabled_for_deployment = true` if VMs need to retrieve TLS certificates.
- Enable diagnostics for PCI-DSS audit logging.
### Example Use Case
An e-commerce platform stores its Stripe API keys and TLS certificates in Key Vault, uses private endpoints for PCI scope reduction, configures certificate auto-renewal for its storefront domains, and grants secrets access only to the checkout service's managed identity.

## Education
### Compliance Requirements
- FERPA, COPPA
### Configuration Changes
- Set `purge_protection_enabled = true` to prevent accidental deletion of encryption keys protecting student records.
- Set `public_network_access_enabled = false` with `enable_private_endpoint = true`.
- Store database credentials and integration API keys as `secrets` with `content_type` descriptions.
- Configure `role_assignments` with "Key Vault Secrets User" for the student information system application.
- Set `enable_diagnostics = true` to audit all access to secrets containing student data credentials.
- Create `keys` for encrypting student data at rest with appropriate rotation policies.
### Example Use Case
A school district stores its student database credentials and SIS API keys in Key Vault with private endpoint access, RBAC restricting access to the SIS application identity, and diagnostic logs for FERPA auditing of credential access.

## SaaS / Multi-Tenant
### Compliance Requirements
- SOC 2, ISO 27001
### Configuration Changes
- Deploy separate Key Vaults per tenant or per tenant tier for strong isolation.
- Set `enable_rbac_authorization = true` and configure `role_assignments` per tenant's managed identity.
- Configure `keys` per tenant for data encryption with independent `rotation_policy` schedules.
- Set `public_network_access_enabled = false` with `enable_private_endpoint = true` per tenant's VNet.
- Configure `network_acls` with `virtual_network_subnet_ids` restricting access to tenant-specific subnets.
- Set `enable_diagnostics = true` for SOC 2 audit evidence of key and secret access patterns.
- Use `certificates` with auto-renewal for tenant-specific TLS certificates.
### Example Use Case
A SaaS provider creates per-tenant Key Vaults, each with tenant-specific encryption keys, RBAC granting access only to that tenant's managed identity, private endpoint in the tenant's subnet, and diagnostic logs proving key access isolation for SOC 2 audits.

## Cross-Industry Best Practices
- Use environment-based configuration by parameterizing `name`, `resource_group_name`, and `tags` per environment.
- Always enable encryption at rest by using Key Vault-managed keys with appropriate `key_type` and `key_size`.
- Enable audit logging and monitoring by setting `enable_diagnostics = true` with `log_analytics_workspace_id`.
- Enforce least-privilege access controls by setting `enable_rbac_authorization = true` and creating fine-grained `role_assignments`.
- Implement network segmentation by setting `public_network_access_enabled = false` and using `enable_private_endpoint = true`.
- Configure backup and disaster recovery by enabling `purge_protection_enabled = true`, `soft_delete_retention_days = 90`, and replicating Key Vault across paired regions.

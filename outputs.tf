output "key_vault_id" {
  description = "The ID of the Key Vault."
  value       = azurerm_key_vault.this.id
}

output "key_vault_name" {
  description = "The name of the Key Vault."
  value       = azurerm_key_vault.this.name
}

output "key_vault_uri" {
  description = "The URI of the Key Vault."
  value       = azurerm_key_vault.this.vault_uri
}

output "key_vault_tenant_id" {
  description = "The tenant ID of the Key Vault."
  value       = azurerm_key_vault.this.tenant_id
}

output "key_ids" {
  description = "Map of Key Vault key names to their IDs."
  value       = { for k, v in azurerm_key_vault_key.this : k => v.id }
}

output "key_versions" {
  description = "Map of Key Vault key names to their current versions."
  value       = { for k, v in azurerm_key_vault_key.this : k => v.version }
}

output "key_versionless_ids" {
  description = "Map of Key Vault key names to their versionless IDs."
  value       = { for k, v in azurerm_key_vault_key.this : k => v.versionless_id }
}

output "secret_ids" {
  description = "Map of Key Vault secret names to their IDs."
  value       = { for k, v in azurerm_key_vault_secret.this : k => v.id }
}

output "secret_versionless_ids" {
  description = "Map of Key Vault secret names to their versionless IDs."
  value       = { for k, v in azurerm_key_vault_secret.this : k => v.versionless_id }
}

output "certificate_ids" {
  description = "Map of Key Vault certificate names to their IDs."
  value       = { for k, v in azurerm_key_vault_certificate.this : k => v.id }
}

output "certificate_versionless_ids" {
  description = "Map of Key Vault certificate names to their versionless IDs."
  value       = { for k, v in azurerm_key_vault_certificate.this : k => v.versionless_id }
}

output "private_endpoint_id" {
  description = "The ID of the private endpoint, if created."
  value       = try(azurerm_private_endpoint.this[0].id, null)
}

output "private_endpoint_ip_address" {
  description = "The private IP address of the private endpoint, if created."
  value       = try(azurerm_private_endpoint.this[0].private_service_connection[0].private_ip_address, null)
}

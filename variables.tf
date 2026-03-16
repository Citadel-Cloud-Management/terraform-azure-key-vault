variable "name" {
  description = "The name of the Key Vault."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group for the Key Vault."
  type        = string
}

variable "location" {
  description = "The Azure region where the Key Vault will be created."
  type        = string
}

variable "sku_name" {
  description = "The SKU name of the Key Vault (standard or premium)."
  type        = string
  default     = "standard"

  validation {
    condition     = contains(["standard", "premium"], var.sku_name)
    error_message = "The sku_name must be either 'standard' or 'premium'."
  }
}

variable "enable_rbac_authorization" {
  description = "Whether to enable RBAC authorization for the Key Vault."
  type        = bool
  default     = true
}

variable "purge_protection_enabled" {
  description = "Whether purge protection is enabled for the Key Vault."
  type        = bool
  default     = true
}

variable "soft_delete_retention_days" {
  description = "The number of days to retain soft-deleted items (7-90)."
  type        = number
  default     = 90

  validation {
    condition     = var.soft_delete_retention_days >= 7 && var.soft_delete_retention_days <= 90
    error_message = "The soft_delete_retention_days must be between 7 and 90."
  }
}

variable "enabled_for_deployment" {
  description = "Whether VMs can retrieve certificates stored as secrets."
  type        = bool
  default     = false
}

variable "enabled_for_disk_encryption" {
  description = "Whether Azure Disk Encryption can retrieve secrets and unwrap keys."
  type        = bool
  default     = false
}

variable "enabled_for_template_deployment" {
  description = "Whether Azure Resource Manager can retrieve secrets."
  type        = bool
  default     = false
}

variable "public_network_access_enabled" {
  description = "Whether public network access is enabled for the Key Vault."
  type        = bool
  default     = false
}

variable "network_acls" {
  description = "Network ACL configuration for the Key Vault."
  type = object({
    bypass                     = optional(string, "AzureServices")
    default_action             = optional(string, "Deny")
    ip_rules                   = optional(list(string), [])
    virtual_network_subnet_ids = optional(list(string), [])
  })
  default = null
}

variable "keys" {
  description = "Map of Key Vault keys to create."
  type = map(object({
    key_type = string
    key_size = optional(number, 2048)
    key_opts = optional(list(string), ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"])
    rotation_policy = optional(object({
      automatic = optional(object({
        time_before_expiry  = optional(string)
        time_after_creation = optional(string)
      }))
      expire_after         = optional(string)
      notify_before_expiry = optional(string)
    }))
  }))
  default = {}
}

variable "secrets" {
  description = "Map of Key Vault secrets to create."
  type = map(object({
    value           = string
    content_type    = optional(string)
    expiration_date = optional(string)
  }))
  default   = {}
  sensitive = true
}

variable "certificates" {
  description = "Map of Key Vault certificates to create."
  type = map(object({
    issuer             = optional(string, "Self")
    exportable         = optional(bool, true)
    key_size           = optional(number, 2048)
    key_type           = optional(string, "RSA")
    content_type       = optional(string, "application/x-pkcs12")
    subject            = string
    dns_names          = optional(list(string), [])
    validity_in_months = optional(number, 12)
  }))
  default = {}
}

variable "role_assignments" {
  description = "Map of role assignments to create on the Key Vault."
  type = map(object({
    principal_id         = string
    role_definition_name = string
  }))
  default = {}
}

variable "enable_private_endpoint" {
  description = "Whether to create a private endpoint for the Key Vault."
  type        = bool
  default     = true
}

variable "private_endpoint_subnet_id" {
  description = "The ID of the subnet for the private endpoint."
  type        = string
  default     = null
}

variable "private_dns_zone_id" {
  description = "The ID of the private DNS zone for the private endpoint."
  type        = string
  default     = null
}

variable "enable_diagnostics" {
  description = "Whether to enable diagnostic settings for the Key Vault."
  type        = bool
  default     = true
}

variable "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics workspace for diagnostic settings."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to all resources."
  type        = map(string)
  default     = {}
}

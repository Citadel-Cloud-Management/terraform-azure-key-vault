resource "azurerm_resource_group" "test" {
  name     = "rg-keyvault-test"
  location = "eastus2"
}

data "azurerm_client_config" "current" {}

module "test" {
  source = "../"

  name                = "kv-test-vault"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  sku_name                  = "standard"
  enable_rbac_authorization = true
  purge_protection_enabled  = true
  soft_delete_retention_days = 90

  public_network_access_enabled = true
  enable_private_endpoint       = false
  enable_diagnostics            = false

  keys = {
    app-key = {
      key_type = "RSA"
      key_size = 2048
      key_opts = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]
    }
  }

  role_assignments = {
    deployer = {
      principal_id         = data.azurerm_client_config.current.object_id
      role_definition_name = "Key Vault Secrets Officer"
    }
  }

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
  }
}

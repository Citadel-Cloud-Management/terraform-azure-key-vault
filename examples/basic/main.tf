provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-keyvault-basic"
  location = "East US"
}

module "key_vault" {
  source = "../../"

  name                = "kv-basic-example"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  enable_private_endpoint = false
  enable_diagnostics      = false

  tags = {
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}

output "key_vault_id" {
  value = module.key_vault.key_vault_id
}

output "key_vault_uri" {
  value = module.key_vault.key_vault_uri
}

# Create storage account and storage container to store Terraform state

resource "azurerm_resource_group" "terraform" {
  name     = "terraform-rg"
  location = var.location
  tags     = var.tags
}

resource "azurerm_storage_account" "terraform_infrastructure_core" {
  name                = "tfinfracorest${random_id.default.dec}"
  resource_group_name = azurerm_resource_group.terraform.name
  location            = var.location
  tags                = var.tags

  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "terraform_infrastructure_core" {
  name                 = "terraform-backend"
  storage_account_name = azurerm_storage_account.terraform_infrastructure_core.name
}

# Secret store for infrastructure-core resources
# https://github.com/schnerring/infrastructure-core
#
# To manage Key Vault secrets, the user requires the `Key Vault Administrator`
# and `Key Vault Secrets Officer` roles.
#
# To access Key Vault secrets, the user requires the `Key Vault Secrets User`
# role.

resource "azurerm_key_vault" "terraform_infrastructure_core" {
  name                = "tfinfracorekv${random_id.default.dec}"
  location            = azurerm_resource_group.terraform.location
  resource_group_name = azurerm_resource_group.terraform.name
  tenant_id           = data.azurerm_subscription.subscription.tenant_id
  tags                = var.tags

  sku_name                  = "standard"
  enable_rbac_authorization = true

  # Many secrets inside this KV are managed manually, e.g., the Matrix Synapse
  # signing key. To protect against accidental or malicious deletion of these
  # secrets, enforce keeping soft-deleted secrets for the duration of retention
  # period.
  purge_protection_enabled   = true
  soft_delete_retention_days = 90
}

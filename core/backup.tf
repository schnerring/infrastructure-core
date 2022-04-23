resource "azurerm_resource_group" "backup" {
  name     = "backup-rg"
  location = var.location
}

resource "azurerm_data_protection_backup_vault" "backup" {
  name                = "backup-bv"
  resource_group_name = azurerm_resource_group.backup.name
  location            = azurerm_resource_group.backup.location

  datastore_type = "VaultStore"
  redundancy     = "LocallyRedundant"

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_data_protection_backup_policy_blob_storage" "p30d" {
  name               = "blob-30d-bp"
  vault_id           = azurerm_data_protection_backup_vault.backup.id
  retention_duration = "P30D" # ISO 8601 - 30 day duration
}

resource "azurerm_role_assignment" "terraform_infrastructure_core" {
  scope                = azurerm_storage_account.terraform_infrastructure_core.id
  role_definition_name = "Storage Account Backup Contributor"
  principal_id         = azurerm_data_protection_backup_vault.backup.identity[0].principal_id
}

resource "azurerm_data_protection_backup_instance_blob_storage" "terraform_infrastructure_core" {
  name     = "terraform-infrastructure-core-bb"
  location = azurerm_resource_group.backup.location

  vault_id           = azurerm_data_protection_backup_vault.backup.id
  backup_policy_id   = azurerm_data_protection_backup_policy_blob_storage.p30d.id
  storage_account_id = azurerm_storage_account.terraform_infrastructure_core.id

  depends_on = [azurerm_role_assignment.terraform_infrastructure_core]
}

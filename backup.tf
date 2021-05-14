resource "azurerm_resource_group" "backup" {
  name     = "backup-rg"
  location = var.location
}

# TODO
# Backup vaults are not (yet?) supported, so we need to manually create the backup vault etc.
# https://docs.microsoft.com/en-us/azure/backup/backup-managed-disks
# https://docs.microsoft.com/en-us/azure/backup/blob-backup-configure-manage

resource "azurerm_recovery_services_vault" "backup" {
  name                = "backup-rsv"
  resource_group_name = azurerm_resource_group.backup.name
  location            = var.location
  sku                 = "Standard"
}

resource "azurerm_backup_policy_file_share" "backup" {
  name                = "backup-1d-policy"
  resource_group_name = azurerm_resource_group.backup.name
  recovery_vault_name = azurerm_recovery_services_vault.backup.name

  backup {
    frequency = "Daily"
    time      = "02:30"
  }

  retention_daily {
    count = 7
  }
}

resource "azurerm_backup_container_storage_account" "k8s" {
  resource_group_name = azurerm_resource_group.backup.name
  recovery_vault_name = azurerm_recovery_services_vault.backup.name
  storage_account_id  = data.azurerm_storage_account.k8s_generated.id
}

data "azurerm_storage_account" "k8s_generated" {
  name                = "f8797dce8b2a6486ca3894d" # AKS auto-generated
  resource_group_name = azurerm_kubernetes_cluster.k8s.node_resource_group
}

resource "azurerm_backup_protected_file_share" "remark42" {
  resource_group_name       = azurerm_resource_group.backup.name
  recovery_vault_name       = azurerm_recovery_services_vault.backup.name
  source_storage_account_id = data.azurerm_storage_account.k8s_generated.id
  source_file_share_name    = "kubernetes-dynamic-pvc-041de38a-81a4-47fc-9c07-a33cfef961c4" # AKS auto-generated
  backup_policy_id          = azurerm_backup_policy_file_share.backup.id

  depends_on = [azurerm_backup_container_storage_account.k8s]
}

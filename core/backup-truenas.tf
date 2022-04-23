# TrueNAS backup resources

resource "azurerm_resource_group" "backup_truenas" {
  name     = "truenas-backup-rg"
  location = var.location
  tags     = var.tags
}

resource "azurerm_storage_account" "backup_truenas" {
  name                = "truenasbackupst${random_id.default.dec}"
  resource_group_name = azurerm_resource_group.backup_truenas.name
  location            = var.location
  tags                = var.tags

  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_management_policy" "backup_truenas" {
  storage_account_id = azurerm_storage_account.backup_truenas.id

  rule {
    name    = "rule1"
    enabled = true
    filters {
      blob_types = ["blockBlob"]
    }
    actions {
      base_blob {
        tier_to_cool_after_days_since_modification_greater_than = 7
      }
      snapshot {
        delete_after_days_since_creation_greater_than = 30
      }
    }
  }
}

locals {
  backup_datasets = [
    "misc",
    "apps",
    "archive",
    "backup",
    "books",
    "documents",
    "games",
    "media",
    "pictures",
    "syncthing",
    "tech",
    "test", # ^^
    "backup-k8s",
    "obs"
  ]
}

resource "azurerm_storage_container" "backup_truenas" {
  count                = length(local.backup_datasets)
  name                 = local.backup_datasets[count.index]
  storage_account_name = azurerm_storage_account.backup_truenas.name
}

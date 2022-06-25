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
  backup_datasets = toset([
    "misc",
    "arrs",
    "backup",
    "backup-k8s",
    "books",
    "documents",
    "games",
    "home",
    "hp-scan",
    "obs",
    "paperless",
    "photoprism",
    "pictures",
    "scripts",
    "syncthing",
    "tech",
    "test" # TODO can remove?
  ])
}

resource "azurerm_storage_container" "backup_truenas" {
  for_each             = local.backup_datasets
  name                 = each.key
  storage_account_name = azurerm_storage_account.backup_truenas.name
}

# TrueNAS backup resources

resource "azurerm_resource_group" "truenas_backup" {
  name     = "truenas-backup-rg"
  location = var.location
  tags     = var.tags
}

resource "azurerm_storage_account" "truenas_backup" {
  name                = "truenasbackupst${random_id.tf_st_id.dec}"
  resource_group_name = azurerm_resource_group.truenas_backup.name
  location            = var.location
  tags                = var.tags

  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "truenas_backup" {
  name                 = "pools"
  storage_account_name = azurerm_storage_account.truenas_backup.name
}

resource "azurerm_storage_management_policy" "truenas_backup" {
  storage_account_id = azurerm_storage_account.truenas_backup.id

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

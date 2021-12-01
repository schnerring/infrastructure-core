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

resource "azurerm_storage_container" "truenas_backup_misc" {
  name                 = "misc"
  storage_account_name = azurerm_storage_account.truenas_backup.name
}

resource "azurerm_storage_container" "truenas_backup_apps" {
  name                 = "apps"
  storage_account_name = azurerm_storage_account.truenas_backup.name
}

resource "azurerm_storage_container" "truenas_backup_archive" {
  name                 = "archive"
  storage_account_name = azurerm_storage_account.truenas_backup.name
}

resource "azurerm_storage_container" "truenas_backup_backup" {
  name                 = "backup"
  storage_account_name = azurerm_storage_account.truenas_backup.name
}

resource "azurerm_storage_container" "truenas_backup_books" {
  name                 = "books"
  storage_account_name = azurerm_storage_account.truenas_backup.name
}

resource "azurerm_storage_container" "truenas_backup_documents" {
  name                 = "documents"
  storage_account_name = azurerm_storage_account.truenas_backup.name
}

resource "azurerm_storage_container" "truenas_backup_games" {
  name                 = "games"
  storage_account_name = azurerm_storage_account.truenas_backup.name
}

resource "azurerm_storage_container" "truenas_backup_pictures" {
  name                 = "pictures"
  storage_account_name = azurerm_storage_account.truenas_backup.name
}

resource "azurerm_storage_container" "truenas_backup_syncthing" {
  name                 = "syncthing"
  storage_account_name = azurerm_storage_account.truenas_backup.name
}

resource "azurerm_storage_container" "truenas_backup_tech" {
  name                 = "tech"
  storage_account_name = azurerm_storage_account.truenas_backup.name
}

resource "azurerm_storage_container" "truenas_backup_test" {
  name                 = "test"
  storage_account_name = azurerm_storage_account.truenas_backup.name
}

# FreeNAS backup resources

locals {
  # TODO: Change to Switzerland North as soon as Archive tier for Azure Blob Storage is supported
  freenas_backup_location = "West Europe"
}

resource "azurerm_resource_group" "freenas_backup_rg" {
  name     = "freenas-backup-rg"
  location = local.freenas_backup_location
  tags     = var.tags
}

resource "random_id" "freenas_backup_st_id" {
  byte_length = 1
}

resource "azurerm_storage_account" "freenas_backup_st" {
  name                = "freenasbackupst${random_id.tf_st_id.dec}"
  resource_group_name = azurerm_resource_group.freenas_backup_rg.name
  location            = local.freenas_backup_location
  tags                = var.tags

  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "freenas_backup_stctn" {
  name                 = "freenas-backup-stctn"
  storage_account_name = azurerm_storage_account.freenas_backup_st.name
}

resource "azurerm_storage_management_policy" "freenas_backup_st_policy" {
  storage_account_id = azurerm_storage_account.freenas_backup_st.id

  rule {
    name    = "rule1"
    enabled = true
    filters {
      blob_types = ["blockBlob"]
    }
    actions {
      base_blob {
        tier_to_cool_after_days_since_modification_greater_than    = 7
        tier_to_archive_after_days_since_modification_greater_than = 30
      }
      snapshot {
        delete_after_days_since_creation_greater_than = 30
      }
    }
  }
}

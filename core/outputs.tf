output "truenas_backup_account_name" {
  value     = azurerm_storage_account.truenas_backup.name
  sensitive = true
}

output "truenas_backup_account_key" {
  value     = azurerm_storage_account.truenas_backup.secondary_access_key
  sensitive = true
}

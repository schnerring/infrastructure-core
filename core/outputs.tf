output "backup_truenas_account_name" {
  value     = azurerm_storage_account.backup_truenas.name
  sensitive = true
}

output "backup_truenas_account_key" {
  value     = azurerm_storage_account.backup_truenas.secondary_access_key
  sensitive = true
}

# DNS Servers

output "schnerring_net_dns_servers" {
  value = cloudflare_zone.schnerring_net.name_servers
}

output "sensingskies_org_dns_servers" {
  value = cloudflare_zone.sensingskies_org.name_servers
}

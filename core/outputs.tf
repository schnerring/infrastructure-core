output "backup_truenas_account_name" {
  value     = azurerm_storage_account.backup_truenas.name
  sensitive = true
}

output "backup_truenas_account_key" {
  value     = azurerm_storage_account.backup_truenas.secondary_access_key
  sensitive = true
}

output "cloudflare_schnerring_net_zone_id" {
  value = cloudflare_zone.schnerring_net.id
}

output "schnerring_net_dns_servers" {
  value = cloudflare_zone.schnerring_net.name_servers
}

output "sensingskies_org_dns_servers" {
  value = cloudflare_zone.sensingskies_org.name_servers
}

output "aks_kube_config_raw" {
  value     = azurerm_kubernetes_cluster.web_core.kube_config_raw
  sensitive = true
}

output "aks_host" {
  value     = azurerm_kubernetes_cluster.web_core.kube_config.0.host
  sensitive = true
}

output "aks_client_certificate" {
  value     = azurerm_kubernetes_cluster.web_core.kube_config.0.client_certificate
  sensitive = true
}

output "aks_client_key" {
  value     = azurerm_kubernetes_cluster.web_core.kube_config.0.client_key
  sensitive = true
}

output "aks_cluster_ca_certificate" {
  value     = azurerm_kubernetes_cluster.web_core.kube_config.0.cluster_ca_certificate
  sensitive = true
}

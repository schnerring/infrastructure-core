output "dns_name_servers" {
  value       = cloudflare_zone.schnerring_net.name_servers
  description = "Cloudflare-assigned name servers."
}

output "kube_config" {
  value       = azurerm_kubernetes_cluster.k8s.kube_config_raw
  description = "kubeconfig for kubectl access."
  sensitive   = true
}

output "postgres_admin_username" {
  value       = var.postgres_username
  description = "PostgreSQL administrator password."
  sensitive   = true
}

output "postgres_admin_password" {
  value       = random_password.postgres.result
  description = "PostgreSQL administrator password."
  sensitive   = true
}

output "plausible_admin_password" {
  value       = random_password.plausible_admin_pwd.result
  description = "Terraform-generated Plausible administrator password."
  sensitive   = true
}

output "freenas_backup_account_name" {
  value       = azurerm_storage_account.freenas_backup.name
  description = "FreeNAS cloud credential account name."
  sensitive   = true
}

output "freenas_backup_account_key" {
  value       = azurerm_storage_account.freenas_backup.secondary_access_key
  description = "FreeNAS cloud credential account key."
  sensitive   = true
}

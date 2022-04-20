output "dns_name_servers" {
  value       = cloudflare_zone.schnerring_net.name_servers
  description = "Cloudflare-assigned schnerring.net name servers."
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

output "remark42_admin_password" {
  value       = random_password.remark42_admin_password.result
  description = "Terraform-generated Remark42 administrator password."
  sensitive   = true
}

output "truenas_backup_account_name" {
  value       = module.core.truenas_backup_account_name
  description = "TrueNAS cloud credential account name."
  sensitive   = true
}

output "truenas_backup_account_key" {
  value       = module.core.truenas_backup_account_key
  description = "TrueNAS cloud credential account key."
  sensitive   = true
}

output "sensingskies_org_dns_name_servers" {
  value       = cloudflare_zone.sensingskies_org.name_servers
  description = "Cloudflare-assigned sensingskies.org name servers."
}

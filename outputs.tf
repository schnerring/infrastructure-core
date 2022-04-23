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
  value       = module.kubernetes.plausible_admin_password
  description = "Terraform-generated Plausible administrator password."
  sensitive   = true
}

output "remark42_admin_password" {
  value       = module.kubernetes.remark42_admin_password
  description = "Terraform-generated Remark42 administrator password."
  sensitive   = true
}

output "backup_truenas_account_name" {
  value       = module.core.backup_truenas_account_name
  description = "TrueNAS cloud credential account name."
  sensitive   = true
}

output "backup_truenas_account_key" {
  value       = module.core.backup_truenas_account_key
  description = "TrueNAS cloud credential account key."
  sensitive   = true
}

output "schnerring_net_dns_servers" {
  value       = module.core.schnerring_net_dns_servers
  description = "Cloudflare-assigned schnerring.net DNS servers."
}

output "sensingskies_org_dns_servers" {
  value       = module.core.sensingskies_org_dns_servers
  description = "Cloudflare-assigned sensingskies.org DNS servers."
}

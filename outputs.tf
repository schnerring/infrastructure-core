output "dns_name_servers" {
  value       = cloudflare_zone.schnerring_net.name_servers
  description = "Cloudflare-assigned name servers."
}

output "kube_config" {
  value       = azurerm_kubernetes_cluster.k8s.kube_config_raw
  description = "kubeconfig for kubectl access."
  sensitive   = true
}

output "plausible_admin_password" {
  value       = random_password.plausible_admin_pwd.result
  description = "Terraform-generated Plausible administrator password."
  sensitive   = true
}

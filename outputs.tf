output "dns_name_servers" {
  value       = cloudflare_zone.schnerring_net_zone.name_servers
  description = "Cloudflare-assigned name servers."
}

output "kube_config" {
  value       = azurerm_kubernetes_cluster.k8s_aks.kube_config_raw
  description = "kubeconfig for kubectl access."
  sensitive   = true
}

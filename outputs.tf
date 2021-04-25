output "kube_config" {
  value       = azurerm_kubernetes_cluster.k8s_aks.kube_config_raw
  sensitive   = true
  description = "kubeconfig for kubectl access."
}

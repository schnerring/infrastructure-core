resource "kubernetes_namespace" "k8s_cert_manager_ns" {
  metadata {
    name = "cert-manager"
  }
}

resource "helm_release" "k8s_cert_manager_helm" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "1.3.1"
  namespace  = kubernetes_namespace.k8s_cert_manager_ns.metadata[0].name
}

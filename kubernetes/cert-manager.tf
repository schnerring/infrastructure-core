# cert-manager

resource "kubernetes_namespace" "cert_manager" {
  metadata {
    name = "cert-manager"
  }
}

resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = var.cert_manager_helm_chart_version
  namespace  = kubernetes_namespace.cert_manager.metadata.0.name

  set {
    name  = "installCRDs"
    value = "true"
  }
}

resource "azurerm_resource_group" "k8s_rg" {
  name     = "k8s-rg"
  location = var.location
}

resource "azurerm_kubernetes_cluster" "k8s_aks" {
  name                = "k8s-aks"
  resource_group_name = azurerm_resource_group.k8s_rg.name
  location            = var.location
  tags                = var.tags

  dns_prefix = "k8saks${random_id.random.dec}"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_B2s"
  }

  identity {
    type = "SystemAssigned"
  }
}

# cert-manager

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

  set {
    name  = "installCRDs"
    value = "true"
  }
}

# Traefik v2

resource "kubernetes_namespace" "traefik_ns" {
  metadata {
    name = "traefik"
  }
}

resource "helm_release" "traefik_helm" {
  name       = "traefik"
  repository = "https://helm.traefik.io/traefik"
  chart      = "traefik"
  version    = "9.18.2"
  namespace  = kubernetes_namespace.traefik_ns.metadata[0].name
}

data "kubernetes_service" "traefik_svc" {
  metadata {
    name      = helm_release.traefik_helm.name
    namespace = helm_release.traefik_helm.namespace
  }
}

resource "cloudflare_record" "traefik" {
  zone_id = cloudflare_zone.schnerring_net_zone.id
  name    = "*.traefik"
  type    = "A"
  value   = data.kubernetes_service.traefik_svc.status.0.load_balancer.0.ingress.0.ip
}

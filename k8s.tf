resource "azurerm_resource_group" "k8s" {
  name     = "k8s-rg"
  location = var.location
}

resource "azurerm_kubernetes_cluster" "k8s" {
  name                      = "k8s-aks"
  resource_group_name       = azurerm_resource_group.k8s.name
  location                  = var.location
  tags                      = var.tags
  automatic_channel_upgrade = "stable"

  dns_prefix = "k8saks${random_id.random.dec}"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_B2ms"
  }

  identity {
    type = "SystemAssigned"
  }
}

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
  version    = "v1.7.1"
  namespace  = kubernetes_namespace.cert_manager.metadata.0.name

  set {
    name  = "installCRDs"
    value = "true"
  }
}

# Let's Encrypt

resource "kubernetes_secret" "letsencrypt_cloudflare_api_token_secret" {
  metadata {
    name      = "letsencrypt-cloudflare-api-token-secret"
    namespace = kubernetes_namespace.cert_manager.metadata.0.name
  }

  data = {
    "api-token" = var.letsencrypt_cloudflare_api_token
  }
}

resource "kubernetes_manifest" "letsencrypt_issuer_staging" {
  manifest = yamldecode(templatefile(
    "${path.module}/letsencrypt-issuer.tpl.yaml",
    {
      "name"                      = "letsencrypt-staging"
      "email"                     = var.letsencrypt_email
      "server"                    = "https://acme-staging-v02.api.letsencrypt.org/directory"
      "api_token_secret_name"     = kubernetes_secret.letsencrypt_cloudflare_api_token_secret.metadata.0.name
      "api_token_secret_data_key" = keys(kubernetes_secret.letsencrypt_cloudflare_api_token_secret.data).0
    }
  ))

  depends_on = [helm_release.cert_manager]
}

resource "kubernetes_manifest" "letsencrypt_issuer_production" {
  manifest = yamldecode(templatefile(
    "${path.module}/letsencrypt-issuer.tpl.yaml",
    {
      "name"                      = "letsencrypt-production"
      "email"                     = var.letsencrypt_email
      "server"                    = "https://acme-v02.api.letsencrypt.org/directory"
      "api_token_secret_name"     = kubernetes_secret.letsencrypt_cloudflare_api_token_secret.metadata.0.name
      "api_token_secret_data_key" = keys(kubernetes_secret.letsencrypt_cloudflare_api_token_secret.data).0
    }
  ))

  depends_on = [helm_release.cert_manager]
}

# Traefik v2

resource "kubernetes_namespace" "traefik" {
  metadata {
    name = "traefik"
  }
}

resource "helm_release" "traefik" {
  name       = "traefik"
  repository = "https://helm.traefik.io/traefik"
  chart      = "traefik"
  version    = "10.14.2"
  namespace  = kubernetes_namespace.traefik.metadata[0].name

  set {
    name  = "ports.web.redirectTo"
    value = "websecure"
  }

  # Trust private AKS IP range
  set {
    name  = "additionalArguments"
    value = "{--entryPoints.websecure.forwardedHeaders.trustedIPs=10.0.0.0/8}"
  }
}

data "kubernetes_service" "traefik" {
  metadata {
    name      = helm_release.traefik.name
    namespace = helm_release.traefik.namespace
  }
}

resource "cloudflare_record" "traefik" {
  zone_id = cloudflare_zone.schnerring_net.id
  name    = "k8s"
  type    = "A"
  value   = data.kubernetes_service.traefik.status.0.load_balancer.0.ingress.0.ip
  proxied = true
}

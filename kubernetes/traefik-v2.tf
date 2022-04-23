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
  version    = var.traefik_helm_chart_version
  namespace  = kubernetes_namespace.traefik.metadata[0].name

  # Permanent HTTP to HTTPS redirect
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
  zone_id = var.cloudflare_schnerring_net_zone_id
  name    = "k8s"
  type    = "A"
  value   = data.kubernetes_service.traefik.status.0.load_balancer.0.ingress.0.ip
  proxied = true
}

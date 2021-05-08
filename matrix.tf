resource "kubernetes_namespace" "matrix" {
  metadata {
    name = "matrix"
  }
}

resource "kubernetes_service" "matrix" {
  metadata {
    name      = "matrix-svc"
    namespace = kubernetes_namespace.matrix.metadata.0.name
  }

  spec {
    selector = {
      "app" = "matrix"
    }

    port {
      name        = "http"
      port        = 8448
      target_port = 8448
    }
  }
}

resource "cloudflare_record" "matrix" {
  zone_id = cloudflare_zone.schnerring_net.id
  name    = "matrix.schnerring.net"
  type    = "CNAME"
  value   = "matrix.k8s.schnerring.net"
  ttl     = 86400
}

resource "cloudflare_record" "matrix_delegation" {
  zone_id = cloudflare_zone.schnerring_net.id
  name    = "_matrix._tcp.schnerring.net"
  type    = "SRV"
  ttl     = 3600

  data = {
    service  = "_matrix"
    proto    = "_tcp"
    name     = "matrix-srv"
    priority = 0
    weight   = 0
    port     = 443
    target   = "matrix.schnerring.net"
  }
}

resource "kubernetes_ingress" "matrix" {
  metadata {
    name      = "matrix-ing"
    namespace = kubernetes_namespace.matrix.metadata.0.name
    annotations = {
      "cert-manager.io/cluster-issuer"           = "letsencrypt-staging"
      "traefik.ingress.kubernetes.io/router.tls" = "true"
    }
  }

  spec {
    rule {
      host = cloudflare_record.matrix.hostname

      http {
        path {
          path = "/"

          backend {
            service_name = "matrix-svc"
            service_port = 8448
          }
        }
      }
    }

    tls {
      hosts       = [cloudflare_record.matrix.hostname]
      secret_name = "matrix-tls-secret"
    }
  }
}

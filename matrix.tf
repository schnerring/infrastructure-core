resource "kubernetes_namespace" "matrix" {
  metadata {
    name = "matrix"
  }
}

resource "cloudflare_record" "matrix" {
  zone_id = cloudflare_zone.schnerring_net.id
  name    = "matrix.schnerring.net"
  type    = "CNAME"
  value   = "matrix.k8s.schnerring.net"
  ttl     = 86400
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
            service_port = 8000
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

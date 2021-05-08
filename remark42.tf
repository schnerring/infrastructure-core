resource "kubernetes_namespace" "remark42" {
  metadata {
    name = "remark42"
  }
}

resource "kubernetes_persistent_volume_claim" "remark42" {
  metadata {
    name      = "remark42-pvc"
    namespace = kubernetes_namespace.remark42.metadata.0.name
    labels = {
      "app" = "remark42-pvc"
    }
  }

  spec {
    access_modes = ["ReadWriteOnce"] # TODO azurefile / ReadWriteMany?

    resources {
      requests = {
        "storage" = "100Mi"
      }
    }
  }
}

locals {
  remark42_image_version = "v1.7.1"
}

resource "random_password" "remark42_secret" {
  length = 64
}

resource "kubernetes_secret" "remark42" {
  metadata {
    name      = "remark42-secret"
    namespace = kubernetes_namespace.remark42.metadata.0.name
  }

  # See also: https://github.com/umputun/remark42#parameters
  data = {
    "REMARK_URL" = "https://${cloudflare_record.remark42.hostname}"
    "SECRET"     = random_password.remark42_secret.result
    "SITE"       = "schnerring.net"

    # SMTP
    "SMTP_HOST"     = var.smtp_host
    "SMTP_PORT"     = var.smtp_port
    "SMTP_USERNAME" = var.smtp_username
    "SMTP_PASSWORD" = var.smtp_port
    "SMTP_TLS"      = "true"

    # Authentication
    "AUTH_ANON"        = "false"
    "AUTH_GITHUB_CID"  = var.remark42_auth_github_cid
    "AUTH_GITHUB_CSEC" = var.remark42_auth_github_csec
  }
}

resource "kubernetes_deployment" "remark42" {
  metadata {
    name      = "remark42-deploy"
    namespace = kubernetes_namespace.remark42.metadata.0.name
    labels = {
      "app" = "remark42"
    }
  }
  spec {
    replicas = 1

    selector {
      match_labels = {
        "app" = "remark42"
      }
    }

    strategy {
      type = "Recreate"
    }

    template {
      metadata {
        labels = {
          "app" = "remark42"
        }
      }

      spec {
        hostname       = "remark42"
        restart_policy = "Always"

        container {
          name  = "remark42"
          image = "umputun/remark42:${local.remark42_image_version}"

          port {
            container_port = 8080
          }

          env {
            name = "REMARK_URL"

            value_from {
              secret_key_ref {
                key  = "REMARK_URL"
                name = "remark42-secret"
              }
            }
          }

          env {
            name = "SECRET"

            value_from {
              secret_key_ref {
                key  = "SECRET"
                name = "remark42-secret"
              }
            }
          }

          env {
            name = "SITE"

            value_from {
              secret_key_ref {
                key  = "SITE"
                name = "remark42-secret"
              }
            }
          }

          env {
            name = "AUTH_ANON"

            value_from {
              secret_key_ref {
                key  = "AUTH_ANON"
                name = "remark42-secret"
              }
            }
          }

          env {
            name = "AUTH_GITHUB_CID"

            value_from {
              secret_key_ref {
                key  = "AUTH_GITHUB_CID"
                name = "remark42-secret"
              }
            }
          }

          env {
            name = "AUTH_GITHUB_CSEC"

            value_from {
              secret_key_ref {
                key  = "AUTH_GITHUB_CSEC"
                name = "remark42-secret"
              }
            }
          }

          env {
            name = "SMTP_HOST"

            value_from {
              secret_key_ref {
                key  = "SMTP_HOST"
                name = "remark42-secret"
              }
            }
          }

          env {
            name = "SMTP_PORT"

            value_from {
              secret_key_ref {
                key  = "SMTP_PORT"
                name = "remark42-secret"
              }
            }
          }

          env {
            name = "SMTP_USERNAME"

            value_from {
              secret_key_ref {
                key  = "SMTP_USERNAME"
                name = "remark42-secret"
              }
            }
          }

          env {
            name = "SMTP_PASSWORD"

            value_from {
              secret_key_ref {
                key  = "SMTP_PASSWORD"
                name = "remark42-secret"
              }
            }
          }

          env {
            name = "SMTP_TLS"

            value_from {
              secret_key_ref {
                key  = "SMTP_TLS"
                name = "remark42-secret"
              }
            }
          }

          volume_mount {
            mount_path = "/srv/var"
            name       = "remark42-vol"
          }
        }

        volume {
          name = "remark42-vol"

          persistent_volume_claim {
            claim_name = "remark42-pvc"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "remark42" {
  metadata {
    name      = "remark42-svc"
    namespace = kubernetes_namespace.remark42.metadata.0.name
  }

  spec {
    selector = {
      "app" = "remark42"
    }

    port {
      name        = "http"
      port        = 80
      target_port = 8080
    }
  }
}

resource "cloudflare_record" "remark42" {
  zone_id = cloudflare_zone.schnerring_net.id
  name    = "remark42.schnerring.net"
  type    = "CNAME"
  value   = "remark42.k8s.schnerring.net"
  ttl     = 86400
}

resource "kubernetes_ingress" "remark42" {
  metadata {
    name      = "remark42-ing"
    namespace = kubernetes_namespace.remark42.metadata.0.name
    annotations = {
      "cert-manager.io/cluster-issuer"           = "letsencrypt-production"
      "traefik.ingress.kubernetes.io/router.tls" = "true"
    }
  }

  spec {
    rule {
      host = cloudflare_record.remark42.hostname

      http {
        path {
          path = "/"

          backend {
            service_name = "remark42-svc"
            service_port = 80
          }
        }
      }
    }

    tls {
      hosts       = [cloudflare_record.remark42.hostname]
      secret_name = "remark42-tls-secret"
    }
  }
}

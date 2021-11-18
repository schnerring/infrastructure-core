resource "kubernetes_namespace" "remark42" {
  metadata {
    name = "remark42"
  }
}

resource "cloudflare_record" "remark42" {
  zone_id = cloudflare_zone.schnerring_net.id
  name    = "remark42"
  type    = "CNAME"
  value   = cloudflare_record.traefik.hostname
  proxied = true
}

resource "kubernetes_persistent_volume_claim" "remark42" {
  metadata {
    name      = "remark42-pvc"
    namespace = kubernetes_namespace.remark42.metadata.0.name
  }

  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = "azurefile"

    resources {
      requests = {
        "storage" = "1Gi"
      }
    }
  }
}

# See also: https://github.com/umputun/remark42#parameters

resource "kubernetes_config_map" "remark42" {
  metadata {
    name      = "remark42-cm"
    namespace = kubernetes_namespace.remark42.metadata.0.name
  }

  data = {
    "REMARK_URL"         = "https://${cloudflare_record.remark42.hostname}"
    "SITE"               = "schnerring.net"
    "ADMIN_SHARED_ID"    = join(",", var.remark42_admin_shared_ids)
    "NOTIFY_TYPE"        = "email"
    "NOTIFY_EMAIL_ADMIN" = "true"
    "AUTH_EMAIL_ENABLE"  = "true"
  }
}

resource "random_password" "remark42_secret" {
  length = 64
}

resource "kubernetes_secret" "remark42" {
  metadata {
    name      = "remark42-secret"
    namespace = kubernetes_namespace.remark42.metadata.0.name
  }

  data = {
    "SECRET" = random_password.remark42_secret.result

    "SMTP_HOST"     = var.smtp_host
    "SMTP_PORT"     = var.smtp_port
    "SMTP_USERNAME" = var.smtp_username
    "SMTP_PASSWORD" = var.smtp_password
    "SMTP_TLS"      = "true"

    "AUTH_ANON" = "true"

    "AUTH_GITHUB_CID"  = var.remark42_auth_github_cid
    "AUTH_GITHUB_CSEC" = var.remark42_auth_github_csec

    "AUTH_TWITTER_CID"  = var.remark42_auth_twitter_cid
    "AUTH_TWITTER_CSEC" = var.remark42_auth_twitter_csec

    "ADMIN_SHARED_EMAIL" = join(",", var.remark42_admin_shared_emails)
    "AUTH_EMAIL_FROM"    = var.remark42_email_from
    "NOTIFY_EMAIL_FROM"  = var.remark42_email_from
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

        # see https://github.com/umputun/baseimage/blob/master/base.alpine/Dockerfile
        # security_context {
        #   run_as_user     = "1001"
        #   run_as_group    = "1001"
        #   fs_group        = "1001"
        #   run_as_non_root = true
        # }

        container {
          name  = "remark42"
          image = "umputun/remark42:${var.remark42_image_version}"

          # security_context {
          #   read_only_root_filesystem = true
          # }

          port {
            container_port = 8080
          }

          env_from {
            secret_ref {
              name = "remark42-secret"
            }
          }

          env_from {
            config_map_ref {
              name = "remark42-cm"
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

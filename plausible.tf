resource "kubernetes_namespace" "plausible" {
  metadata {
    name = "plausible"
  }
}

resource "kubernetes_persistent_volume_claim" "event_data" {
  metadata {
    name      = "event-data-pvc"
    namespace = kubernetes_namespace.plausible.metadata.0.name
  }

  spec {
    access_modes = ["ReadWriteOnce"] # TODO azurefile / ReadWriteMany?

    resources {
      requests = {
        "storage" = "1Gi"
      }
    }
  }
}

resource "kubernetes_config_map" "event_data" {
  metadata {
    name      = "event-data-cm"
    namespace = kubernetes_namespace.plausible.metadata.0.name
  }

  data = {
    # https://github.com/plausible/hosting/blob/master/clickhouse/clickhouse-config.xml
    "clickhouse-config.xml" = <<-CLICKHOUSE_CONFIG
      <yandex>
          <logger>
              <level>warning</level>
              <console>true</console>
          </logger>

          <!-- Stop all the unnecessary logging -->
          <query_thread_log remove="remove"/>
          <query_log remove="remove"/>
          <text_log remove="remove"/>
          <trace_log remove="remove"/>
          <metric_log remove="remove"/>
          <asynchronous_metric_log remove="remove"/>
      </yandex>
    CLICKHOUSE_CONFIG

    # https://github.com/plausible/hosting/blob/master/clickhouse/clickhouse-user-config.xml
    "clickhouse-user-config.xml" = <<-CLICKHOUSE_USER_CONFIG
      <yandex>
          <profiles>
              <default>
                  <log_queries>0</log_queries>
                  <log_query_threads>0</log_query_threads>
              </default>
          </profiles>
      </yandex>
    CLICKHOUSE_USER_CONFIG
  }
}

resource "kubernetes_stateful_set" "event_data" {
  metadata {
    name      = "event-data-sts"
    namespace = kubernetes_namespace.plausible.metadata.0.name
  }

  spec {
    replicas     = 1
    service_name = "event-data"

    selector {
      match_labels = {
        "app" = "event-data"
      }
    }

    template {
      metadata {
        labels = {
          "app" = "event-data"
        }
      }

      spec {
        restart_policy = "Always"

        container {
          name  = "event-data"
          image = "yandex/clickhouse-server:${var.clickhouse_image_version}"

          port {
            container_port = 8123
          }

          volume_mount {
            mount_path = "/var/lib/clickhouse"
            name       = "event-data-vol"
          }

          volume_mount {
            name       = "config-vol"
            mount_path = "/etc/clickhouse-server/config.d/logging.xml"
            sub_path   = "clickhouse-config.xml"
            read_only  = true
          }

          volume_mount {
            name       = "config-vol"
            mount_path = "/etc/clickhouse-server/users.d/logging.xml"
            sub_path   = "clickhouse-user-config.xml"
            read_only  = true
          }
        }

        volume {
          name = "event-data-vol"

          persistent_volume_claim {
            claim_name = "event-data-pvc"
          }
        }

        volume {
          name = "config-vol"

          config_map {
            name = "event-data-cm"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "event_data" {
  metadata {
    name      = "event-data-svc"
    namespace = kubernetes_namespace.plausible.metadata.0.name
  }

  spec {
    port {
      port        = 8123
      target_port = 8123
    }

    selector = {
      "app" = "event-data"
    }
  }
}

resource "random_password" "plausible_admin_pwd" {
  length = 64
}

resource "random_password" "plausible_secret_key_base" {
  length = 128
}

locals {
  plausible_db_name = "plausible"
}

resource "kubernetes_secret" "plausible" {
  metadata {
    name      = "plausible-secret"
    namespace = kubernetes_namespace.plausible.metadata.0.name
  }

  # See also: https://plausible.io/docs/self-hosting-configuration
  data = {
    # Default User Generation
    "ADMIN_USER_EMAIL" = var.plausible_admin_email
    "ADMIN_USER_NAME"  = var.plausible_admin_name
    "ADMIN_USER_PWD"   = random_password.plausible_admin_pwd.result

    # Server
    "BASE_URL"             = "https://${cloudflare_record.plausible.hostname}"
    "SECRET_KEY_BASE"      = base64encode(random_password.plausible_secret_key_base.result)
    "DISABLE_REGISTRATION" = "true"

    # Database
    "DATABASE_URL"            = "postgres://${var.postgres_username}:${urlencode(random_password.postgres.result)}@${var.postgres_service_name}-headless.${kubernetes_namespace.postgres.metadata.0.name}:${var.postgres_service_port}/${local.plausible_db_name}?ssl=false"
    "CLICKHOUSE_DATABASE_URL" = "http://event-data-svc:8123/${local.plausible_db_name}"

    # SMTP
    "MAILER_EMAIL"          = var.plausible_mailer_email
    "SMTP_HOST_ADDR"        = var.smtp_host
    "SMTP_HOST_PORT"        = var.smtp_port
    "SMTP_USER_NAME"        = var.smtp_username
    "SMTP_USER_PWD"         = var.smtp_password
    "SMTP_HOST_SSL_ENABLED" = "true"
    "SMTP_RETRIES"          = "2"
  }
}

resource "kubernetes_deployment" "plausible" {
  metadata {
    name      = "plausible-deploy"
    namespace = kubernetes_namespace.plausible.metadata.0.name
    labels = {
      "app" = "plausible"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "app" = "plausible"
      }
    }

    template {
      metadata {
        labels = {
          "app" = "plausible"
        }
      }

      spec {
        restart_policy = "Always"

        init_container {
          name  = "plausible-init"
          image = "plausible/analytics:${var.plausible_image_version}"

          command = ["sh"]

          args = [
            "-c",
            "sleep 10 && /entrypoint.sh db createdb && /entrypoint.sh db migrate && /entrypoint.sh db init-admin"
          ]

          env {
            name = "ADMIN_USER_EMAIL"

            value_from {
              secret_key_ref {
                key  = "ADMIN_USER_EMAIL"
                name = "plausible-secret"
              }
            }
          }

          env {
            name = "ADMIN_USER_NAME"

            value_from {
              secret_key_ref {
                key  = "ADMIN_USER_NAME"
                name = "plausible-secret"
              }
            }
          }

          env {
            name = "ADMIN_USER_PWD"

            value_from {
              secret_key_ref {
                key  = "ADMIN_USER_PWD"
                name = "plausible-secret"
              }
            }
          }

          env {
            name = "BASE_URL"

            value_from {
              secret_key_ref {
                key  = "BASE_URL"
                name = "plausible-secret"
              }
            }
          }

          env {
            name = "SECRET_KEY_BASE"

            value_from {
              secret_key_ref {
                key  = "SECRET_KEY_BASE"
                name = "plausible-secret"
              }
            }
          }

          env {
            name = "DISABLE_REGISTRATION"

            value_from {
              secret_key_ref {
                key  = "DISABLE_REGISTRATION"
                name = "plausible-secret"
              }
            }
          }

          env {
            name = "DATABASE_URL"

            value_from {
              secret_key_ref {
                key  = "DATABASE_URL"
                name = "plausible-secret"
              }
            }
          }

          env {
            name = "CLICKHOUSE_DATABASE_URL"

            value_from {
              secret_key_ref {
                key  = "CLICKHOUSE_DATABASE_URL"
                name = "plausible-secret"
              }
            }
          }

          env {
            name = "MAILER_EMAIL"

            value_from {
              secret_key_ref {
                key  = "MAILER_EMAIL"
                name = "plausible-secret"
              }
            }
          }

          env {
            name = "SMTP_HOST_ADDR"

            value_from {
              secret_key_ref {
                key  = "SMTP_HOST_ADDR"
                name = "plausible-secret"
              }
            }
          }

          env {
            name = "SMTP_HOST_PORT"

            value_from {
              secret_key_ref {
                key  = "SMTP_HOST_PORT"
                name = "plausible-secret"
              }
            }
          }

          env {
            name = "SMTP_USER_NAME"

            value_from {
              secret_key_ref {
                key  = "SMTP_USER_NAME"
                name = "plausible-secret"
              }
            }
          }

          env {
            name = "SMTP_USER_PWD"

            value_from {
              secret_key_ref {
                key  = "SMTP_USER_PWD"
                name = "plausible-secret"
              }
            }
          }

          env {
            name = "SMTP_HOST_SSL_ENABLED"

            value_from {
              secret_key_ref {
                key  = "SMTP_HOST_SSL_ENABLED"
                name = "plausible-secret"
              }
            }
          }

          env {
            name = "SMTP_RETRIES"

            value_from {
              secret_key_ref {
                key  = "SMTP_RETRIES"
                name = "plausible-secret"
              }
            }
          }
        }

        container {
          name  = "plausible"
          image = "plausible/analytics:${var.plausible_image_version}"

          command = ["sh"]

          args = [
            "-c",
            "sleep 10 && /entrypoint.sh run"
          ]

          port {
            name           = "http"
            container_port = 8000
          }

          env {
            name = "ADMIN_USER_EMAIL"

            value_from {
              secret_key_ref {
                key  = "ADMIN_USER_EMAIL"
                name = "plausible-secret"
              }
            }
          }

          env {
            name = "ADMIN_USER_NAME"

            value_from {
              secret_key_ref {
                key  = "ADMIN_USER_NAME"
                name = "plausible-secret"
              }
            }
          }

          env {
            name = "ADMIN_USER_PWD"

            value_from {
              secret_key_ref {
                key  = "ADMIN_USER_PWD"
                name = "plausible-secret"
              }
            }
          }

          env {
            name = "BASE_URL"

            value_from {
              secret_key_ref {
                key  = "BASE_URL"
                name = "plausible-secret"
              }
            }
          }

          env {
            name = "SECRET_KEY_BASE"

            value_from {
              secret_key_ref {
                key  = "SECRET_KEY_BASE"
                name = "plausible-secret"
              }
            }
          }

          env {
            name = "DISABLE_REGISTRATION"

            value_from {
              secret_key_ref {
                key  = "DISABLE_REGISTRATION"
                name = "plausible-secret"
              }
            }
          }

          env {
            name = "DATABASE_URL"

            value_from {
              secret_key_ref {
                key  = "DATABASE_URL"
                name = "plausible-secret"
              }
            }
          }

          env {
            name = "CLICKHOUSE_DATABASE_URL"

            value_from {
              secret_key_ref {
                key  = "CLICKHOUSE_DATABASE_URL"
                name = "plausible-secret"
              }
            }
          }

          env {
            name = "MAILER_EMAIL"

            value_from {
              secret_key_ref {
                key  = "MAILER_EMAIL"
                name = "plausible-secret"
              }
            }
          }

          env {
            name = "SMTP_HOST_ADDR"

            value_from {
              secret_key_ref {
                key  = "SMTP_HOST_ADDR"
                name = "plausible-secret"
              }
            }
          }

          env {
            name = "SMTP_HOST_PORT"

            value_from {
              secret_key_ref {
                key  = "SMTP_HOST_PORT"
                name = "plausible-secret"
              }
            }
          }

          env {
            name = "SMTP_USER_NAME"

            value_from {
              secret_key_ref {
                key  = "SMTP_USER_NAME"
                name = "plausible-secret"
              }
            }
          }

          env {
            name = "SMTP_USER_PWD"

            value_from {
              secret_key_ref {
                key  = "SMTP_USER_PWD"
                name = "plausible-secret"
              }
            }
          }

          env {
            name = "SMTP_HOST_SSL_ENABLED"

            value_from {
              secret_key_ref {
                key  = "SMTP_HOST_SSL_ENABLED"
                name = "plausible-secret"
              }
            }
          }

          env {
            name = "SMTP_RETRIES"

            value_from {
              secret_key_ref {
                key  = "SMTP_RETRIES"
                name = "plausible-secret"
              }
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "plausible" {
  metadata {
    name      = "plausible-svc"
    namespace = kubernetes_namespace.plausible.metadata.0.name
  }

  spec {
    selector = {
      "app" = "plausible"
    }

    port {
      name        = "http"
      port        = 8000
      target_port = 8000
    }
  }
}

resource "cloudflare_record" "plausible" {
  zone_id = cloudflare_zone.schnerring_net.id
  name    = "plausible"
  type    = "CNAME"
  value   = "plausible.k8s.schnerring.net"
  ttl     = 86400
}

resource "kubernetes_ingress" "plausible" {
  metadata {
    name      = "plausible-ing"
    namespace = kubernetes_namespace.plausible.metadata.0.name
    annotations = {
      "cert-manager.io/cluster-issuer"           = "letsencrypt-production"
      "traefik.ingress.kubernetes.io/router.tls" = "true"
    }
  }

  spec {
    rule {
      host = cloudflare_record.plausible.hostname

      http {
        path {
          path = "/"

          backend {
            service_name = "plausible-svc"
            service_port = 8000
          }
        }
      }
    }

    tls {
      hosts       = [cloudflare_record.plausible.hostname]
      secret_name = "plausible-tls-secret"
    }
  }
}

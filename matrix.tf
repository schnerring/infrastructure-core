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
      port        = 8008
      target_port = 8008
    }
  }
}

resource "kubernetes_persistent_volume_claim" "matrix" {
  metadata {
    name      = "matrix-pvc"
    namespace = kubernetes_namespace.matrix.metadata.0.name
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    resources {
      requests = {
        "storage" = "1Gi"
      }
    }
  }
}

resource "kubernetes_secret" "matrix" {
  metadata {
    name      = "matrix-secret"
    namespace = kubernetes_namespace.matrix.metadata.0.name
  }

  # See also: https://github.com/matrix-org/synapse/blob/master/docker/README.md#generating-a-configuration-file
  data = {
    "homeserver.yaml" = templatefile(
      "${path.module}/synapse-config/homeserver.tpl.yaml", {
        "server_name"                = var.synapse_server_name
        "report_stats"               = var.synapse_report_stats
        "log_config"                 = "/data/${var.synapse_server_name}.log.config"
        "registration_shared_secret" = var.synapse_registration_shared_secret
        "macaroon_secret_key"        = var.synapse_macaroon_secret_key
        "form_secret"                = var.synapse_form_secret
        "signing_key_path"           = "/data/${var.synapse_server_name}.signing.key"
      }
    )
    "log.config" = file("${path.module}/synapse-config/log.tpl.config",
      {
        "synapse_log_file_path" = "/data/homeserver.log"
        "synapse_log_level"     = "INFO"
      }
    )
    "signing.key" = var.synapse_signing_key
  }
}

resource "kubernetes_deployment" "matrix" {
  metadata {
    name      = "matrix-deploy"
    namespace = kubernetes_namespace.matrix.metadata.0.name
    labels = {
      "app" = "matrix"
    }
  }
  spec {
    replicas = 1

    selector {
      match_labels = {
        "app" = "matrix"
      }
    }

    strategy {
      type = "Recreate"
    }

    template {
      metadata {
        labels = {
          "app" = "matrix"
        }
      }

      spec {
        hostname       = "matrix"
        restart_policy = "Always"

        init_container {
          args  = ["generate"]
          name  = "synapse-init"
          image = "matrixdotorg/synapse:${var.synapse_image_version}"

          env {
            name  = "SYNAPSE_SERVER_NAME"
            value = var.synapse_server_name
          }

          env {
            name  = "SYNAPSE_REPORT_STATS"
            value = var.synapse_report_stats ? "yes" : "no"
          }

          env {
            name  = "LOG_FILE_PATH"
            value = local.synapse_log_file_path
          }

          volume_mount {
            mount_path = "/data"
            name       = "data-vol"
          }

          volume_mount {
            name       = "config-vol"
            mount_path = "/data/homeserver.yaml"
            sub_path   = "homeserver.yaml"
            read_only  = true
          }

          volume_mount {
            name       = "config-vol"
            mount_path = "/data/${var.synapse_server_name}.log.config"
            sub_path   = "log.config"
            read_only  = true
          }
        }

        container {
          name  = "synapse"
          image = "matrixdotorg/synapse:${var.synapse_image_version}"

          port {
            container_port = 8008
          }

          volume_mount {
            mount_path = "/data"
            name       = "data-vol"
          }

          volume_mount {
            name       = "config-vol"
            mount_path = "/data/homeserver.yaml"
            sub_path   = "homeserver.yaml"
            read_only  = true
          }

          volume_mount {
            name       = "config-vol"
            mount_path = "/data/${var.synapse_server_name}.log.config"
            sub_path   = "log.config"
            read_only  = true
          }
        }

        volume {
          name = "data-vol"

          persistent_volume_claim {
            claim_name = "matrix-pvc"
          }
        }

        volume {
          name = "config-vol"

          secret {
            secret_name = "matrix-secret"
          }
        }
      }
    }
  }
}

resource "cloudflare_record" "matrix" {
  zone_id = cloudflare_zone.schnerring_net.id
  name    = "matrix"
  type    = "A"
  value   = cloudflare_record.traefik.value
  ttl     = 86400
}

resource "cloudflare_record" "matrix_delegation" {
  zone_id = cloudflare_zone.schnerring_net.id
  name    = "_matrix._tcp"
  type    = "SRV"
  ttl     = 86400

  data = {
    service  = "_matrix"
    proto    = "_tcp"
    name     = var.synapse_server_name
    priority = 0
    weight   = 0
    port     = 443
    target   = cloudflare_record.matrix.hostname
  }
}

resource "kubernetes_ingress" "matrix" {
  metadata {
    name      = "matrix-ing"
    namespace = kubernetes_namespace.matrix.metadata.0.name
    annotations = {
      "cert-manager.io/cluster-issuer"           = "letsencrypt-production"
      "traefik.ingress.kubernetes.io/router.tls" = "true"
    }
  }

  spec {
    rule {
      host = var.synapse_server_name

      http {
        path {
          path = "/_matrix"

          backend {
            service_name = "matrix-svc"
            service_port = 8008
          }
        }

        path {
          path = "/_synapse/client"

          backend {
            service_name = "matrix-svc"
            service_port = 8008
          }
        }
      }
    }

    rule {
      host = cloudflare_record.matrix.hostname

      http {
        path {
          path = "/_matrix"

          backend {
            service_name = "matrix-svc"
            service_port = 8008
          }
        }

        path {
          path = "/_synapse/client"

          backend {
            service_name = "matrix-svc"
            service_port = 8008
          }
        }
      }
    }

    tls {
      secret_name = "matrix-tls-secret"

      hosts = [
        var.synapse_server_name,
        cloudflare_record.matrix.hostname
      ]
    }
  }
}

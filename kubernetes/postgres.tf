resource "kubernetes_namespace" "postgres" {
  metadata {
    name = "postgres"
  }
}

resource "kubernetes_secret" "postgres" {
  metadata {
    name      = "postgres-secret"
    namespace = kubernetes_namespace.postgres.metadata.0.name
  }

  data = {
    "POSTGRES_USER"     = var.postgres_username
    "POSTGRES_PASSWORD" = var.postgres_password
  }
}

resource "kubernetes_persistent_volume_claim" "postgres" {
  metadata {
    name      = "postgres-pvc"
    namespace = kubernetes_namespace.postgres.metadata.0.name
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    resources {
      requests = {
        # `default` storage class uses Standard SSDs
        # https://docs.microsoft.com/en-us/azure/virtual-machines/disks-types#standard-ssd-size
        "storage" = "8Gi"
      }
    }
  }
}

locals {
  postgres_mount_path = "/var/lib/postgresql/data"
}

resource "kubernetes_stateful_set" "postgres" {
  metadata {
    name      = "postgres-sts"
    namespace = kubernetes_namespace.postgres.metadata.0.name
  }

  spec {
    replicas     = 1
    service_name = "postgres"

    selector {
      match_labels = {
        "app" = "postgres"
      }
    }

    template {
      metadata {
        labels = {
          "app" = "postgres"
        }
      }

      spec {
        security_context {
          run_as_user     = "999"
          run_as_group    = "999"
          fs_group        = "999"
          run_as_non_root = true
        }

        container {
          name  = "postgres"
          image = "postgres:${var.postgres_image_version}"

          port {
            name           = "postgres"
            container_port = 5432
          }

          env_from {
            secret_ref {
              name = "postgres-secret"
            }
          }

          env {
            name  = "PGDATA"
            value = "${local.postgres_mount_path}/pgdata"
          }

          volume_mount {
            mount_path = local.postgres_mount_path
            name       = "data-vol"
          }
        }

        volume {
          name = "data-vol"

          persistent_volume_claim {
            claim_name = "postgres-pvc"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "postgres" {
  metadata {
    name      = "postgres-svc"
    namespace = kubernetes_namespace.postgres.metadata.0.name
  }

  spec {
    selector = {
      "app" = "postgres"
    }

    port {
      port        = 5432
      target_port = 5432
    }
  }
}

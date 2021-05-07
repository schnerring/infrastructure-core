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
            name  = "REMARK_URL"
            value = "https://remark42.k8s.schnerring.net"
          }

          env {
            name  = "SITE"
            value = "schnerring.net"
          }

          env {
            name  = "SECRET"
            value = random_password.remark42_secret.result
          }

          env {
            name  = "AUTH_ANON"
            value = "true"
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
      host = "remark42.k8s.schnerring.net"

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
      hosts       = ["remark42.k8s.schnerring.net"]
      secret_name = "remark42-tls-secret"
    }
  }
}

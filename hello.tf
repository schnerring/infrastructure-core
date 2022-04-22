resource "kubernetes_namespace" "hello" {
  metadata {
    name = "hello"
  }
}

resource "kubernetes_deployment" "hello" {
  metadata {
    name      = "hello-deploy"
    namespace = kubernetes_namespace.hello.metadata.0.name

    labels = {
      app = "hello"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "hello"
      }
    }

    template {
      metadata {
        labels = {
          app = "hello"
        }
      }

      spec {
        container {
          image = "nginxdemos/hello"
          name  = "hello"

          port {
            container_port = 80
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "hello" {
  metadata {
    name      = "hello-svc"
    namespace = kubernetes_namespace.hello.metadata.0.name
  }

  spec {
    selector = {
      app = kubernetes_deployment.hello.metadata.0.labels.app
    }

    port {
      port        = 80
      target_port = 80
    }
  }
}

resource "kubernetes_ingress_v1" "hello" {
  metadata {
    name      = "hello-ing"
    namespace = kubernetes_namespace.hello.metadata.0.name
    annotations = {
      "cert-manager.io/cluster-issuer"           = "letsencrypt-production"
      "traefik.ingress.kubernetes.io/router.tls" = "true"
    }
  }

  spec {
    rule {
      host = "hello.k8s.schnerring.net"

      http {
        path {
          path = "/"

          backend {
            service {
              name = "hello-svc"

              port {
                number = 80
              }
            }
          }
        }
      }
    }

    tls {
      hosts       = ["hello.k8s.schnerring.net"]
      secret_name = "hello-tls-secret"
    }
  }
}

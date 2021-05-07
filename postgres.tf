resource "kubernetes_namespace" "postgres" {
  metadata {
    name = "postgres"
  }
}

resource "random_password" "postgres" {
  length = 32
}

resource "kubernetes_secret" "postgres" {
  metadata {
    name      = "postgres-secret"
    namespace = kubernetes_namespace.postgres.metadata.0.name
  }

  data = {
    "postgresql-password" = random_password.postgres.result
  }
}

resource "helm_release" "postgres" {
  name       = "postgres"
  repository = "https://marketplace.azurecr.io/helm/v1/repo"
  chart      = "postgresql"
  version    = var.postgres_helm_chart_version
  namespace  = kubernetes_namespace.postgres.metadata.0.name

  set {
    name  = "existingSecret"
    value = kubernetes_secret.postgres.metadata.0.name
  }

  set {
    name  = "persistence.size"
    value = "500Mi"
  }
}

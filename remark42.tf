resource "kubernetes_namespace" "remark42" {
  metadata {
    name = "remark42"
  }
}

resource "kubernetes_persistent_volume_claim" "remark42" {
  metadata {
    name      = "remark42-pvc"
    namespace = "remark42"
    labels = {
      "app" = "remark42-pvc"
    }
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    resources {
      requests = {
        "storage" = "100Mi"
      }
    }
  }
}

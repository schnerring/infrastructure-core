terraform {
  required_providers {
    helm = {
      source  = "helm"
      version = ">= 2.4.1"
    }

    kubernetes = {
      source  = "kubernetes"
      version = ">= 2.8.0"
    }
  }
}

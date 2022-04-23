terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = ">= 3.9.1"
    }

    helm = {
      source  = "helm"
      version = ">= 2.4.1"
    }

    kubernetes = {
      source  = "kubernetes"
      version = ">= 2.8.0"
    }

    random = {
      source  = "random"
      version = ">= 3.1.2"
    }
  }
}

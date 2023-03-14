terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = ">= 4.1.0"
    }

    helm = {
      source  = "helm"
      version = ">= 2.6.0"
    }

    kubernetes = {
      source  = "kubernetes"
      version = ">= 2.12.1"
    }

    random = {
      source  = "random"
      version = ">= 3.4.3"
    }
  }
}

terraform {
  required_version = ">= 0.15.3"

  required_providers {
    azuread = {
      source  = "azuread"
      version = "=2.7.0"
    }

    azurerm = {
      source  = "azurerm"
      version = "=2.81.0"
    }

    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "=3.2.0"
    }

    github = {
      source  = "integrations/github"
      version = "=4.9.2"
    }

    helm = {
      source  = "helm"
      version = "=2.1.1"
    }

    kubernetes = {
      source  = "kubernetes"
      version = "=2.1.0"
    }

    kubernetes-alpha = {
      source  = "kubernetes-alpha"
      version = "=0.3.2"
    }

    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "1.13.0-pre1"
    }

    random = {
      source  = "random"
      version = "=3.1.0"
    }

    time = {
      source  = "time"
      version = "=0.7.0"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}

provider "cloudflare" {}

provider "helm" {
  kubernetes {
    host = azurerm_kubernetes_cluster.k8s.kube_config.0.host

    client_certificate     = base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.client_certificate)
    client_key             = base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.cluster_ca_certificate)
  }
}

provider "kubernetes" {
  host = azurerm_kubernetes_cluster.k8s.kube_config.0.host

  client_certificate     = base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.cluster_ca_certificate)
}

provider "kubernetes-alpha" {
  host = azurerm_kubernetes_cluster.k8s.kube_config.0.host

  client_certificate     = base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.cluster_ca_certificate)
}

provider "postgresql" {
  host     = "localhost" # kubectl port-forward TODO put into vars?
  port     = 5432
  username = var.postgres_username
  password = random_password.postgres.result
  sslmode  = "disable"
}

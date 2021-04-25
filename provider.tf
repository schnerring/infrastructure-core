terraform {
  required_version = "= 0.14.9"

  required_providers {
    azuread = {
      source  = "azuread"
      version = "=1.4.0"
    }

    azurerm = {
      source  = "azurerm"
      version = "=2.56.0"
    }

    github = {
      source  = "integrations/github"
      version = "=4.9.2"
    }

    helm = {
      source  = "helm"
      version = "=2.1.1"
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

provider "helm" {
  kubernetes {
    host                   = azurerm_kubernetes_cluster.k8s_aks.kube_config.0.host
    client_certificate     = base64decode(azurerm_kubernetes_cluster.k8s_aks.kube_config.0.client_certificate)
    client_key             = base64decode(azurerm_kubernetes_cluster.k8s_aks.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.k8s_aks.kube_config.0.cluster_ca_certificate)
  }
}

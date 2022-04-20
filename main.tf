terraform {
  required_version = ">= 1.1.0"

  required_providers {
    azuread = {
      source  = "azuread"
      version = "=2.18.0"
    }

    azurerm = {
      source  = "azurerm"
      version = "=2.97.0"
    }

    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "=3.9.1"
    }

    github = {
      source  = "integrations/github"
      version = "=4.20.0"
    }

    helm = {
      source  = "helm"
      version = "=2.4.1"
    }

    kubernetes = {
      source  = "kubernetes"
      version = "=2.8.0"
    }

    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "~> 1.15"
    }

    random = {
      source  = "random"
      version = "~> 3.1.2"
    }

    time = {
      source  = "time"
      version = "=0.7.2"
    }
  }
}

provider "postgresql" {
  host     = "localhost" # kubectl port-forward TODO put into vars?
  port     = 5432
  username = var.postgres_username
  password = random_password.postgres.result
  sslmode  = "disable"
}

module "postgres" {
  source = "./postgres"
}

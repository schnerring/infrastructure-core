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

terraform {
  backend "azurerm" {}
}

provider "postgresql" {
  host     = "localhost" # kubectl port-forward TODO put into vars?
  port     = 5432
  username = var.postgres_username
  password = random_password.postgres.result
  sslmode  = "disable"
}

resource "random_password" "matrix_synapse_db" {
  length = 64
}

resource "random_password" "plausible_db" {
  length = 64
}

module "postgres" {
  source = "./postgres"

  matrix_synapse_db       = var.matrix_synapse_db
  matrix_synapse_username = var.matrix_synapse_db_username
  matrix_synapse_password = random_password.matrix_synapse_db.result

  plausible_db       = var.plausible_db
  plausible_username = var.plausible_db_username
  plausible_password = random_password.plausible_db.result
}

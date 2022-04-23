terraform {
  required_version = ">= 1.1.0"

  required_providers {
    azuread = {
      source  = "azuread"
      version = "=2.18.0"
    }

    azurerm = {
      source  = "azurerm"
      version = "~> 2.97.0"
    }

    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 3.9.1"
    }

    github = {
      source  = "integrations/github"
      version = "=4.20.0"
    }

    helm = {
      source  = "helm"
      version = "~> 2.4.1"
    }

    kubernetes = {
      source  = "kubernetes"
      version = "~> 2.8.0"
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

  backend "azurerm" {}
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

provider "postgresql" {
  host     = "localhost" # kubectl port-forward TODO put into vars?
  port     = 5432
  username = var.postgres_username
  password = random_password.postgres.result
  sslmode  = "disable"
}

module "core" {
  source = "./core"

  location = var.location
  tags     = var.tags
}

# Postgres passwords

resource "random_password" "postgres" {
  length = 32
}

resource "random_password" "matrix_synapse_db" {
  length = 64
}

resource "random_password" "plausible_db" {
  length = 64
}

# TODO remove?

data "cloudflare_zone" "schnerring_net" {
  name = "schnerring.net"

  # Zone is managed by core module
  depends_on = [
    module.core
  ]
}

module "kubernetes" {
  source = "./kubernetes"

  cloudflare_schnerring_net_zone_id = data.cloudflare_zone.schnerring_net.id

  letsencrypt_cloudflare_api_token = var.letsencrypt_cloudflare_api_token
  letsencrypt_email                = var.letsencrypt_email

  clickhouse_image_version     = var.clickhouse_image_version
  postgres_image_version       = var.postgres_image_version
  plausible_image_version      = var.plausible_image_version
  remark42_image_version       = var.remark42_image_version
  matrix_synapse_image_version = var.matrix_synapse_image_version

  smtp_host     = var.smtp_host
  smtp_port     = var.smtp_port
  smtp_username = var.smtp_username
  smtp_password = var.smtp_password

  postgres_username = var.postgres_username
  postgres_password = random_password.postgres.result

  plausible_db                   = var.plausible_db
  plausible_db_username          = var.plausible_db_username
  plausible_db_password          = random_password.plausible_db.result
  plausible_admin_email          = var.plausible_admin_email
  plausible_admin_name           = var.plausible_admin_name
  plausible_mailer_email         = var.plausible_mailer_email
  plausible_google_client_id     = var.plausible_google_client_id
  plausible_google_client_secret = var.plausible_google_client_secret

  remark42_email_from          = var.remark42_email_from
  remark42_admin_shared_ids    = var.remark42_admin_shared_ids
  remark42_admin_shared_emails = var.remark42_admin_shared_emails
  remark42_auth_github_cid     = var.remark42_auth_github_cid
  remark42_auth_github_csec    = var.remark42_auth_github_csec
  remark42_auth_twitter_cid    = var.remark42_auth_twitter_cid
  remark42_auth_twitter_csec   = var.remark42_auth_twitter_csec

  matrix_synapse_db                         = var.matrix_synapse_db
  matrix_synapse_db_username                = var.matrix_synapse_db_username
  matrix_synapse_db_password                = random_password.matrix_synapse_db.result
  matrix_synapse_server_name                = var.matrix_synapse_server_name
  matrix_synapse_report_stats               = var.matrix_synapse_report_stats
  matrix_synapse_signing_key                = var.matrix_synapse_signing_key
  matrix_synapse_registration_shared_secret = var.matrix_synapse_registration_shared_secret
  matrix_synapse_macaroon_secret_key        = var.matrix_synapse_macaroon_secret_key
  matrix_synapse_form_secret                = var.matrix_synapse_form_secret
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

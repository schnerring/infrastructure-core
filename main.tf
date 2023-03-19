terraform {
  required_version = ">= 1.4.0"

  required_providers {
    azurerm = {
      source  = "azurerm"
      version = "~> 3.47"
    }

    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.1"
    }

    helm = {
      source  = "helm"
      version = "~> 2.9"
    }

    kubernetes = {
      source  = "kubernetes"
      version = "~> 2.18"
    }

    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "~> 1.18.0"
    }

    random = {
      source  = "random"
      version = "~> 3.4"
    }
  }

  backend "azurerm" {}
}

# Providers

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
    host = module.core.aks_host

    client_certificate     = base64decode(module.core.aks_client_certificate)
    client_key             = base64decode(module.core.aks_client_key)
    cluster_ca_certificate = base64decode(module.core.aks_cluster_ca_certificate)
  }
}

provider "kubernetes" {
  host = module.core.aks_host

  client_certificate     = base64decode(module.core.aks_client_certificate)
  client_key             = base64decode(module.core.aks_client_key)
  cluster_ca_certificate = base64decode(module.core.aks_cluster_ca_certificate)
}

provider "postgresql" {
  host     = "localhost" # kubectl port-forward TODO put into vars?
  port     = 5432
  username = var.postgres_username
  password = random_password.postgres.result
  sslmode  = "disable"
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

# Modules

module "core" {
  source = "./core"

  location     = var.location
  aks_location = var.aks_location
  tags         = var.tags

  cloudflare_account_id = var.cloudflare_account_id
}

module "kubernetes" {
  source = "./kubernetes"

  cloudflare_schnerring_net_zone_id = module.core.cloudflare_schnerring_net_zone_id

  letsencrypt_cloudflare_api_token = var.letsencrypt_cloudflare_api_token
  letsencrypt_email                = var.letsencrypt_email

  cert_manager_helm_chart_version = var.cert_manager_helm_chart_version
  traefik_helm_chart_version      = var.traefik_helm_chart_version
  clickhouse_image_version        = var.clickhouse_image_version
  postgres_image_version          = var.postgres_image_version
  plausible_image_version         = var.plausible_image_version
  remark42_image_version          = var.remark42_image_version
  matrix_synapse_image_version    = var.matrix_synapse_image_version

  smtp_host     = var.smtp_host
  smtp_port     = var.smtp_port
  smtp_username = var.smtp_username
  smtp_password = var.smtp_password

  postgres_username = var.postgres_username
  postgres_password = random_password.postgres.result

  plausible_db                   = var.plausible_db
  plausible_db_username          = var.plausible_db_username
  plausible_db_password          = random_password.plausible_db.result
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

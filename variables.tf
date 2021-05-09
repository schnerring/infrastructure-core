variable "location" {
  type        = string
  description = "Azure datacenter location where resources will be deployed to."
  default     = "Switzerland North"
}

variable "tags" {
  type        = map(string)
  description = "Default Azure tags applied to any resource."
  default = {
    "Environment"          = "Production"
    "Management Framework" = "Terraform"
    "Project"              = "infrastructure"
  }
}

variable "letsencrypt_email" {
  type        = string
  description = "Email address that Let's Encrypt will use to send notifications about expiring certificates and account-related issues to."
  sensitive   = true
}

variable "letsencrypt_cloudflare_api_token" {
  type        = string
  description = "Cloudflare API token with Zone-DNS-Edit and Zone-Zone-Read permissions, which is required for DNS01 challenge validation."
  sensitive   = true
}

variable "clickhouse_image_version" {
  type        = string
  description = "Clickhouse DB image version"
  default     = "21.3.9.83" # LTS release: https://github.com/ClickHouse/ClickHouse/releases/tag/v21.3.9.83-lts
}

variable "postgres_helm_chart_version" {
  type        = string
  description = "bitnami/postgresql Helm Chart version"
  default     = "10.4.2"
}

variable "postgres_username" {
  type        = string
  description = "Postgres username."
  default     = "postgres"
}

variable "postgres_service_name" {
  type        = string
  description = "Postgres service name."
  default     = "postgres"
}

variable "postgres_service_port" {
  type        = string
  description = "Postgres service port."
  default     = "5432"
}

variable "plausible_image_version" {
  type        = string
  description = "Plausible image version"
  default     = "v1.3"
}

variable "plausible_admin_email" {
  type        = string
  description = "Plausible administrator email address."
  sensitive   = true
}

variable "plausible_admin_name" {
  type        = string
  description = "Plausible administrator username."
  sensitive   = true
}

variable "plausible_mailer_email" {
  type        = string
  description = "Email address to use as FROM address of all communications from Plausible."
  sensitive   = true
}

variable "smtp_host" {
  type        = string
  description = "SMTP server address."
  sensitive   = true
}

variable "smtp_port" {
  type        = string
  description = "SMTP server port (implicit TLS)."
  sensitive   = true
}

variable "smtp_username" {
  type        = string
  description = "SMTP authentication username."
  sensitive   = true
}

variable "smtp_password" {
  type        = string
  description = "SMTP authentication password."
  sensitive   = true
}

variable "remark42_image_version" {
  type        = string
  description = "Remark42 image version"
  default     = "v1.7.1"
}

variable "remark42_mailer_email" {
  type        = string
  description = "Email address to use as FROM address of all communications from Remark42."
}

variable "remark42_auth_github_cid" {
  type        = string
  description = "GitHub OAuth client ID."
  sensitive   = true
}

variable "remark42_auth_github_csec" {
  type        = string
  description = "GitHub OAuth client secret."
  sensitive   = true
}

variable "synapse_image_version" {
  type        = string
  description = "Synapse image version."
  default     = "v1.33.1"
}

variable "synapse_image_version" {
  type        = string
  description = "Synapse image version."
  default     = "v1.33.1"
}

variable "synapse_server_name" {
  type        = string
  description = "Public Synapse hostname."
}

variable "synapse_report_stats" {
  type        = bool
  description = "Enable anonymous statistics reporting."
}

variable "synapse_signing_key" {
  type        = string
  description = "Signing key Synapse signs messages with."
  sensitive   = true
}

variable "synapse_registration_shared_secret" {
  type        = string
  description = "Allows registration of standard or admin accounts by anyone who has the shared secret."
  sensitive   = true
}

variable "synapse_macaroon_secret_key" {
  type        = string
  description = "Secret which is used to sign access tokens."
  sensitive   = true
}

variable "synapse_form_secret" {
  type        = string
  description = "Secret which is used to calculate HMACs for form values."
  sensitive   = true
}

variable "location" {
  type        = string
  description = "Azure region where resources will be deployed."
}

variable "tags" {
  type        = map(string)
  description = "Default Azure tags applied to any resource."
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

# Image Versions

variable "clickhouse_image_version" {
  type        = string
  description = "Clickhouse DB image version"
}

variable "postgres_image_version" {
  type        = string
  description = "bitnami/postgresql Helm Chart version"
}

variable "plausible_image_version" {
  type        = string
  description = "Plausible image version"
}

variable "remark42_image_version" {
  type        = string
  description = "Remark42 image version"
}

variable "matrix_synapse_image_version" {
  type        = string
  description = "Synapse image version."
}

# SMTP

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

# Postgres

variable "postgres_username" {
  type        = string
  description = "Postgres username."
  sensitive   = true
}

# Plausible

variable "plausible_db" {
  type        = string
  description = "Plausible Postgres database name."
}

variable "plausible_db_username" {
  type        = string
  description = "Plausible Postgres username."
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

variable "plausible_google_client_id" {
  type        = string
  description = "The Client ID from the Google API Console for Plausible."
  sensitive   = true
}

variable "plausible_google_client_secret" {
  type        = string
  description = "The Client Secret from the Google API Console for Plausible."
  sensitive   = true
}

# Remark42

variable "remark42_email_from" {
  type        = string
  description = "Email address to use as FROM address of all communications from Remark42."
  sensitive   = true
}

variable "remark42_admin_shared_ids" {
  type        = set(string)
  description = "Admin IDs."
}

variable "remark42_admin_shared_emails" {
  type        = set(string)
  description = "Email addresses that Remark42 will send notifications to."
  sensitive   = true
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

variable "remark42_auth_twitter_cid" {
  type        = string
  description = "Twitter OAuth client ID."
  sensitive   = true
}

variable "remark42_auth_twitter_csec" {
  type        = string
  description = "Twitter OAuth client secret."
  sensitive   = true
}

# Matrix Synapse

variable "matrix_synapse_db" {
  type        = string
  description = "Matrix Synapse Postgres database name."
}

variable "matrix_synapse_db_username" {
  type        = string
  description = "Matrix Synapse Postgres username."
}

variable "matrix_synapse_server_name" {
  type        = string
  description = "Public Synapse hostname."
}

variable "matrix_synapse_report_stats" {
  type        = bool
  description = "Enable anonymous statistics reporting."
}

variable "matrix_synapse_signing_key" {
  type        = string
  description = "Signing key Synapse signs messages with."
  sensitive   = true
}

variable "matrix_synapse_registration_shared_secret" {
  type        = string
  description = "Allows registration of standard or admin accounts by anyone who has the shared secret."
  sensitive   = true
}

variable "matrix_synapse_macaroon_secret_key" {
  type        = string
  description = "Secret which is used to sign access tokens."
  sensitive   = true
}

variable "matrix_synapse_form_secret" {
  type        = string
  description = "Secret which is used to calculate HMACs for form values."
  sensitive   = true
}

variable "cloudflare_schnerring_net_zone_id" {
  type = string
}

variable "letsencrypt_email" {
  type      = string
  sensitive = true
}

variable "letsencrypt_cloudflare_api_token" {
  type      = string
  sensitive = true
}

variable "cert_manager_helm_chart_version" {
  type = string
}

variable "traefik_helm_chart_version" {
  type = string
}

variable "clickhouse_image_version" {
  type = string
}

variable "postgres_image_version" {
  type = string
}

variable "plausible_image_version" {
  type = string
}

variable "remark42_image_version" {
  type = string
}

variable "matrix_synapse_image_version" {
  type = string
}

variable "smtp_host" {
  type      = string
  sensitive = true
}

variable "smtp_port" {
  type      = string
  sensitive = true
}

variable "smtp_username" {
  type      = string
  sensitive = true
}

variable "smtp_password" {
  type      = string
  sensitive = true
}

variable "postgres_username" {
  type      = string
  sensitive = true
}

variable "postgres_password" {
  type      = string
  sensitive = true
}

variable "plausible_db" {
  type = string
}

variable "plausible_db_username" {
  type = string
}

variable "plausible_db_password" {
  type      = string
  sensitive = true
}

variable "plausible_admin_email" {
  type      = string
  sensitive = true
}

variable "plausible_admin_name" {
  type      = string
  sensitive = true
}

variable "plausible_mailer_email" {
  type      = string
  sensitive = true
}

variable "plausible_google_client_id" {
  type      = string
  sensitive = true
}

variable "plausible_google_client_secret" {
  type      = string
  sensitive = true
}

variable "remark42_email_from" {
  type      = string
  sensitive = true
}

variable "remark42_admin_shared_ids" {
  type = set(string)
}

variable "remark42_admin_shared_emails" {
  type      = set(string)
  sensitive = true
}

variable "remark42_auth_github_cid" {
  type      = string
  sensitive = true
}

variable "remark42_auth_github_csec" {
  type      = string
  sensitive = true
}

variable "remark42_auth_twitter_cid" {
  type      = string
  sensitive = true
}

variable "remark42_auth_twitter_csec" {
  type      = string
  sensitive = true
}

variable "matrix_synapse_db" {
  type = string
}

variable "matrix_synapse_db_username" {
  type = string
}

variable "matrix_synapse_db_password" {
  type      = string
  sensitive = true
}

variable "matrix_synapse_server_name" {
  type = string
}

variable "matrix_synapse_report_stats" {
  type = bool
}

variable "matrix_synapse_signing_key" {
  type      = string
  sensitive = true
}

variable "matrix_synapse_registration_shared_secret" {
  type      = string
  sensitive = true
}

variable "matrix_synapse_macaroon_secret_key" {
  type      = string
  sensitive = true
}

variable "matrix_synapse_form_secret" {
  type      = string
  sensitive = true
}

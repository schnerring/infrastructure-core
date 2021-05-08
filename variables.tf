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

variable "postgres_helm_chart_version" {
  type        = string
  description = "bitnami/postgresql Helm Chart version"
  default     = "10.4.2"
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

variable "plausible_smtp_host_addr" {
  type        = string
  description = "SMTP server address."
  sensitive   = true
}

variable "plausible_smtp_host_port" {
  type        = string
  description = "SMTP server port (implicit TLS)."
  sensitive   = true
}

variable "plausible_smtp_user_name" {
  type        = string
  description = "SMTP authentication username."
  sensitive   = true
}

variable "plausible_smtp_user_pwd" {
  type        = string
  description = "SMTP authentication password."
  sensitive   = true
}

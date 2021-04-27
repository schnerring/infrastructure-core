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

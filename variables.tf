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
  description = "Email address where Let's Encrypt will contact you about expiring certificates and issues related to your account."
  sensitive   = true
}

variable "letsencrypt_cloudflare_api_token" {
  type        = string
  description = "Cloudflare API token with Zone-DNS-Edit and Zone-Zone-Read permissions, which is required for DNS01 challenge validation."
  sensitive   = true
}

variable "location" {
  type = string
}

variable "aks_location" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "cloudflare_account_id" {
  type      = string
  sensitive = true
}

terraform {
  required_providers {
    azurerm = {
      source  = "azurerm"
      version = ">= 2.97.0"
    }

    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = ">= 3.18.0"
    }

    random = {
      source  = "random"
      version = ">= 3.3.2"
    }
  }
}

data "azurerm_subscription" "subscription" {}

resource "random_id" "default" {
  byte_length = 1
}

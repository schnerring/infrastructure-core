terraform {
  required_providers {
    azurerm = {
      source  = "azurerm"
      version = ">= 3.47.0"
    }

    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = ">= 4.1.0"
    }

    random = {
      source  = "random"
      version = ">= 3.4.3"
    }
  }
}

data "azurerm_subscription" "subscription" {}

resource "random_id" "default" {
  byte_length = 1
}

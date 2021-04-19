terraform {
  required_version = "= 0.14.9"

  required_providers {
    azuread = {
      source  = "azuread"
      version = "=1.4.0"
    }

    azurerm = {
      source  = "azurerm"
      version = "=2.56.0"
    }

    random = {
      source  = "random"
      version = "=3.1.0"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}

terraform {
  required_providers {
    azurerm = {
      source  = "azurerm"
      version = ">= 2.97.0"
    }

    random = {
      source  = "random"
      version = ">= 3.1.2"
    }
  }
}

terraform {
  required_providers {
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = ">= 1.15"
    }

    random = {
      source  = "random"
      version = ">= 3.1.2"
    }
  }
}

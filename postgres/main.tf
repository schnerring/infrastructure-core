terraform {
  required_providers {
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = ">= 1.18.0"
    }

    random = {
      source  = "random"
      version = ">= 3.4.3"
    }
  }
}

terraform {
  required_providers {
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = ">= 1.16"
    }

    random = {
      source  = "random"
      version = ">= 3.4.3"
    }
  }
}

data "azurerm_subscription" "subscription" {}

resource "time_rotating" "sp_password_rotation_interval" {
  rotation_months = 6
}

resource "random_id" "random" {
  byte_length = 2
}

data "cloudflare_zone" "schnerring_net" {
  name = "schnerring.net"

  # Zone is managed in core module
  depends_on = [
    module.core
  ]
}

data "azurerm_subscription" "subscription" {}

resource "time_rotating" "sp_password_rotation_interval" {
  rotation_months = 6
}

resource "random_id" "random" {
  byte_length = 2
}



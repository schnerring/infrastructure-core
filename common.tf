data "azurerm_subscription" "subscription" {}

resource "time_rotating" "sp_password_rotation_interval" {
  rotation_months = 6
}

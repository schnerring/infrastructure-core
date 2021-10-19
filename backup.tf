resource "azurerm_resource_group" "backup" {
  name     = "backup-rg"
  location = var.location
}

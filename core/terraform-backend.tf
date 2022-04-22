# Create storage account and storage container to store Terraform state

resource "azurerm_resource_group" "terraform" {
  name     = "terraform-rg"
  location = var.location
  tags     = var.tags
}

resource "azurerm_storage_account" "terraform_infrastructure_core" {
  name                = "tfinfrastructurest${random_id.default.dec}"
  resource_group_name = azurerm_resource_group.terraform.name
  location            = var.location
  tags                = var.tags

  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "terraform_infrastructure_core" {
  name                 = "infrastructure-stctn"
  storage_account_name = azurerm_storage_account.terraform_infrastructure_core.name
}

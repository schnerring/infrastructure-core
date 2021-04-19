# Create storage account and storage container to store Terraform state

resource "azurerm_resource_group" "tf_rg" {
  name     = "terraform-rg"
  location = var.location
  tags     = var.tags
}

resource "random_id" "tf_st_id" {
  byte_length = 1
}

resource "azurerm_storage_account" "tf_infrastructure_st" {
  name                = "tfinfrastructurest${random_id.tf_st_id.dec}"
  resource_group_name = azurerm_resource_group.tf_rg.name
  location            = var.location
  tags                = var.tags

  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "tf_infrastructure_stctn" {
  name                 = "infrastructure-stctn"
  storage_account_name = azurerm_storage_account.tf_infrastructure_st.name
}

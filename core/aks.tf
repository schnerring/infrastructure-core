resource "azurerm_resource_group" "aks" {
  name     = "aks-rg"
  location = var.aks_location
}

# Azure Kubernetes Service cluster hosting core web services of my website https://schnerring.net
#   - PostgreSQL
#   - Plausible Analytics
#   - Remark42
#   - Matrix Synapse

resource "azurerm_kubernetes_cluster" "web_core" {
  name                = "web-core-aks"
  resource_group_name = azurerm_resource_group.aks.name
  location            = azurerm_resource_group.aks.location
  tags                = var.tags

  automatic_channel_upgrade = "stable"
  dns_prefix                = "web-core-aks-${random_id.default.hex}"

  default_node_pool {
    name            = "default"
    node_count      = 1
    vm_size         = "Standard_D2as_v4"
    os_disk_type    = "Ephemeral"
    os_disk_size_gb = 50
  }

  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "basic"
  }

  identity {
    type = "SystemAssigned"
  }
}

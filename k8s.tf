resource "azurerm_resource_group" "k8s" {
  name     = "k8s-rg"
  location = var.location
}

resource "azurerm_kubernetes_cluster" "k8s" {
  name                      = "k8s-aks"
  resource_group_name       = azurerm_resource_group.k8s.name
  location                  = var.location
  tags                      = var.tags
  automatic_channel_upgrade = "stable"

  dns_prefix = "k8saks${random_id.random.dec}"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_B2ms"
  }

  identity {
    type = "SystemAssigned"
  }
}

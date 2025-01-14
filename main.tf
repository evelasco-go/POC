provider "azurerm" {
  features {}

  # Hardcoded Azure credentials
  client_id       = "9a7b7fdd-5a88-46e3-8d9b-b78042012e30"
  client_secret   = "s6h8Q~WNY_QKu92SobDd7FnfSIWJsYSYmKeF2dw0"
  tenant_id       = "fd3a4a13-0cd8-4c1c-ba4c-e4995f5ee282"
  subscription_id = "15e60859-88d7-4c84-943f-55488479910c"
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-akstest"
  location = "East US"
}

resource "azurerm_storage_account" "storage" {
  name                     = "aksstoragedemo"
  resource_group_name       = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier               = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-demo"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "aksdemodns"

  default_node_pool {
    name       = "default"
    node_count = 2
    vm_size    = "Standard_DS2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    environment = "dev"
  }
}

output "kubeconfig" {
  value = azurerm_kubernetes_cluster.aks.kube_config_raw
}

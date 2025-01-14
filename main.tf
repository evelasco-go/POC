# Provider and authentication setup
provider "azurerm" {
  features {}
  client_id       = "9a7b7fdd-5a88-46e3-8d9b-b78042012e30"
  client_secret   = "s6h8Q~WNY_QKu92SobDd7FnfSIWJsYSYmKeF2dw0"
  tenant_id       = "fd3a4a13-0cd8-4c1c-ba4c-e4995f5ee282"
  subscription_id = "15e60859-88d7-4c84-943f-55488479910c"
}

# Declare variables used in the configuration
variable "aks_name" {
  description = "Name of the AKS cluster"
  type        = string
  default     = "myakscluster"
}

variable "aks_location" {
  description = "Location for the AKS cluster"
  type        = string
  default     = "East US"
}

variable "resource_group_name" {
  description = "Resource group for the AKS cluster"
  type        = string
  default     = "myResourceGroup"
}

# Create the resource group
resource "azurerm_resource_group" "example" {
  name     = var.resource_group_name
  location = var.aks_location
}

# Create the AKS cluster
resource "azurerm_kubernetes_cluster" "example" {
  name                = var.aks_name
  location            = var.aks_location
  resource_group_name = azurerm_resource_group.example.name
  dns_prefix          = "aks-cluster"

  default_node_pool {
    name       = "default"
    node_count = 2
    vm_size    = "Standard_DS2_v2"
  }

  identity {
    type = "SystemAssigned"
  }
}

# Output the kubeconfig (marked as sensitive)
output "kubeconfig" {
  value     = azurerm_kubernetes_cluster.example.kube_config.0.raw_kube_config
  sensitive = true
}

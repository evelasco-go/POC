# Provider and authentication setup
provider "azurerm" {
  features {}
  client_id       = var.azure_client_id
  client_secret   = var.azure_client_secret
  tenant_id       = var.azure_tenant_id
  subscription_id = var.azure_subscription_id
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

variable "azure_client_id" {
  description = "Azure Client ID"
  type        = string
}

variable "azure_client_secret" {
  description = "Azure Client Secret"
  type        = string
}

variable "azure_tenant_id" {
  description = "Azure Tenant ID"
  type        = string
}

variable "azure_subscription_id" {
  description = "Azure Subscription ID"
  type        = string
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
  value     = azurerm_kubernetes_cluster.example.kube_config[0].raw_kube_config
  sensitive = true
}

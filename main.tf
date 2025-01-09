terraform {
  backend "azurerm" {
    resource_group_name  = "POCMyResourceGroup"
    storage_account_name = "pocmystorageacct123"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0" # Ensure compatibility with your Terraform version
    }
  }
}

provider "azurerm" {
  features {}

  azure_subscription_id = "15e60859-88d7-4c84-943f-55488479910c"
  azure_client_id       = "9a7b7fdd-5a88-46e3-8d9b-b78042012e30"
  azure_client_secret   = "s6h8Q~WNY_QKu92SobDd7FnfSIWJsYSYmKeF2dw0"
  azure_tenant_id       = "fd3a4a13-0cd8-4c1c-ba4c-e4995f5ee282"
}

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "example-resource-group"
  location = "East US"
}

# Storage Account for Terraform State
resource "azurerm_storage_account" "storage" {
  name                     = "examplestorageacct123"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Storage Container for State File
resource "azurerm_storage_container" "container" {
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "private"
}

# AKS Cluster
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "example-aks-cluster"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "example-aks-dns"

  default_node_pool {
    name       = "default"
    node_count = 2
    vm_size    = "Standard_DS2_v2"
  }

  identity {
    type = "SystemAssigned"
  }
}

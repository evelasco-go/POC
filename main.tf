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

  subscription_id = "your-subscription-id"  # Replace with your Azure Subscription ID
  client_id       = "your-client-id"        # Replace with your Azure Client ID
  client_secret   = "your-client-secret"    # Replace with your Azure Client Secret
  tenant_id       = "your-tenant-id"        # Replace with your Azure Tenant ID
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

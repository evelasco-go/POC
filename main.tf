terraform {
  required_version = ">= 1.5.7, < 2.0.0"

  backend "azurerm" {
    resource_group_name  = "POCMyResourceGroup"
    storage_account_name = "pocmystorageacct123"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

# Azure Provider Configuration
provider "azurerm" {
  features {}

  subscription_id = var.azure_subscription_id
  client_id       = var.azure_client_id
  client_secret   = var.azure_client_secret
  tenant_id       = var.azure_tenant_id
}

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# Storage Account
resource "azurerm_storage_account" "storage" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Storage Container
resource "azurerm_storage_container" "container" {
  name                  = var.container_name
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "private"
}

# Azure Kubernetes Cluster (AKS)
resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "${var.aks_name}-dns"

  default_node_pool {
    name       = "default"
    node_count = var.node_count
    vm_size    = "Standard_DS2_v2"
  }

  identity {
    type = "SystemAssigned"
  }
}

# Variables
variable "azure_subscription_id" {
  type        = string
  description = "The Azure Subscription ID"
}

variable "azure_client_id" {
  type        = string
  description = "The Azure Client ID"
}

variable "azure_client_secret" {
  type        = string
  description = "The Azure Client Secret"
}

variable "azure_tenant_id" {
  type        = string
  description = "The Azure Tenant ID"
}

variable "resource_group_name" {
  type        = string
  description = "The name of the Resource Group"
  default     = "POCMyResourceGroup"
}

variable "storage_account_name" {
  type        = string
  description = "The name of the Storage Account"
  default     = "pocmystorageacct123"
}

variable "container_name" {
  type        = string
  description = "The name of the Storage Container"
  default     = "tfstate"
}

variable "aks_name" {
  type        = string
  description = "The name of the AKS Cluster"
  default     = "example-aks-cluster"
}

variable "node_count" {
  type        = number
  description = "The number of nodes in the AKS cluster"
  default     = 2
}

variable "location" {
  type        = string
  description = "The Azure region for resources"
  default     = "eastus"
}

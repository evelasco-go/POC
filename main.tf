terraform {
  required_version = ">= 1.5.7, < 2.0.0"  # Match the Terraform version used to create the plan
  
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

provider "azurerm" {
  features {}

  subscription_id = var.azure_subscription_id
  client_id       = var.azure_client_id
  client_secret   = var.azure_client_secret
  tenant_id       = var.azure_tenant_id
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_storage_account" "storage" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "container" {
  name                  = var.container_name
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "private"
}

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

variable "azure_subscription_id" {
  type        = string
  default     = "15e60859-88d7-4c84-943f-55488479910c"
}

variable "azure_client_id" {
  type        = string
  default     = "9a7b7fdd-5a88-46e3-8d9b-b78042012e30"
}

variable "azure_client_secret" {
  type        = string
  default     = "s6h8Q~WNY_QKu92SobDd7FnfSIWJsYSYmKeF2dw0"
}

variable "azure_tenant_id" {
  type        = string
  default     = "fd3a4a13-0cd8-4c1c-ba4c-e4995f5ee282"
}

variable "resource_group_name" {
  type        = string
  default     = "POCMyResourceGroup"
}

variable "storage_account_name" {
  type        = string
  default     = "pocmystorageacct123"
}

variable "container_name" {
  type        = string
  default     = "tfstate"
}

variable "aks_name" {
  type        = string
  default     = "example-aks-cluster"
}

variable "node_count" {
  type        = number
  default     = 2
}

variable "location" {
  type        = string
  default     = "eastus"
}

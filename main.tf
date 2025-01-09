# Terraform Backend Configuration
terraform {
  backend "azurerm" {
    resource_group_name  = "POCMyResourceGroup"
    storage_account_name = "pocmystorageacct123"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}

# Provider Configuration
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

# Storage Account for Terraform State
resource "azurerm_storage_account" "storage" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Storage Container for State File
resource "azurerm_storage_container" "container" {
  name                  = var.container_name
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "private"
}

# AKS Cluster
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

# Variables with Default Values
variable "azure_subscription_id" {
  description = "Azure Subscription ID"
  type        = string
  default     = "15e60859-88d7-4c84-943f-55488479910c"  # Replace with your value
}

variable "azure_client_id" {
  description = "Azure Client ID"
  type        = string
  default     = "9a7b7fdd-5a88-46e3-8d9b-b78042012e30"  # Replace with your value
}

variable "azure_client_secret" {
  description = "Azure Client Secret"
  type        = string
  default     = "s6h8Q~WNY_QKu92SobDd7FnfSIWJsYSYmKeF2dw0"  # Replace with your value
}

variable "azure_tenant_id" {
  description = "Azure Tenant ID"
  type        = string
  default     = "fd3a4a13-0cd8-4c1c-ba4c-e4995f5ee282"  # Replace with your value
}

variable "resource_group_name" {
  description = "Name of the Resource Group"
  type        = string
  default     = "example-resource-group"
}

variable "storage_account_name" {
  description = "Name of the Storage Account for Terraform State"
  type        = string
  default     = "examplestorageacct123"
}

variable "container_name" {
  description = "Name of the Storage Container for Terraform State"
  type        = string
  default     = "tfstate"
}

variable "aks_name" {
  description = "Name of the AKS Cluster"
  type        = string
  default     = "example-aks-cluster"
}

variable "node_count" {
  description = "Number of nodes in the AKS cluster"
  type        = number
  default     = 2
}

variable "location" {
  description = "Azure location for the resources"
  type        = string
  default     = "East US"
}

terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = {
      source = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

# Provider configuration for Azure
provider "azurerm" {
  features {}
  client_id       = var.azure_client_id
  client_secret   = var.azure_client_secret
  tenant_id       = var.azure_tenant_id
  subscription_id = var.azure_subscription_id
}

# Provider configuration for random ID generation
provider "random" {}

# Define variables
variable "azure_subscription_id" {}
variable "azure_client_id" {}
variable "azure_client_secret" {}
variable "azure_tenant_id" {}
variable "resource_group_name" {}
variable "storage_account_name" {}
variable "container_name" {}
variable "aks_name" {}
variable "node_count" {}
variable "location" {}
variable "log_analytics_workspace_name" {}
variable "log_analytics_sku" {}
variable "diagnostic_setting_name" {}

# Data source for existing resource group
data "azurerm_resource_group" "existing" {
  name = var.resource_group_name
}

# Data source for existing storage account
data "azurerm_storage_account" "existing" {
  name                = var.storage_account_name
  resource_group_name = var.resource_group_name
}

# Data source for existing storage container
data "azurerm_storage_container" "existing" {
  name                  = var.container_name
  storage_account_name  = var.storage_account_name
}

# Data source for existing Log Analytics Workspace
data "azurerm_log_analytics_workspace" "existing" {
  name                = var.log_analytics_workspace_name
  resource_group_name = var.resource_group_name
}

# Data source for existing AKS cluster
data "azurerm_kubernetes_cluster" "existing" {
  name                = var.aks_name
  resource_group_name = var.resource_group_name
}

# Resource group - only create if it doesn't already exist
resource "azurerm_resource_group" "example" {
  count    = length(data.azurerm_resource_group.existing.id) == 0 ? 1 : 0
  name     = var.resource_group_name
  location = var.location
  lifecycle {
    prevent_destroy = true
  }
}

# Azure Kubernetes Service Cluster - only create if it doesn't already exist
resource "azurerm_kubernetes_cluster" "example" {
  count                = length(data.azurerm_kubernetes_cluster.existing.id) == 0 ? 1 : 0
  name                 = var.aks_name
  location             = var.location
  resource_group_name  = azurerm_resource_group.example[0].name
  dns_prefix           = "aks-cluster"

  default_node_pool {
    name       = "default"
    node_count = var.node_count
    vm_size    = "Standard_DS2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  depends_on = [azurerm_resource_group.example]  # Ensure resource group is created before AKS
}

# Output kubeconfig (sensitive)
output "kubeconfig" {
  value     = azurerm_kubernetes_cluster.example[0].kube_config
  sensitive = true
}

# Azure Storage Account - only create if it doesn't already exist
resource "azurerm_storage_account" "example" {
  count                    = length(data.azurerm_storage_account.existing.id) == 0 ? 1 : 0
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.example[0].name
  location                 = var.location
  account_tier              = "Standard"
  account_replication_type = "LRS"
  depends_on = [azurerm_resource_group.example]  # Ensure resource group is created first
}

# Storage Container Resource - only create if it doesn't already exist
resource "azurerm_storage_container" "example" {
  count                     = length(data.azurerm_storage_container.existing.id) == 0 ? 1 : 0
  name                      = var.container_name
  storage_account_name      = azurerm_storage_account.example[0].name
  container_access_type     = "private"
  lifecycle {
    prevent_destroy = true
  }
  depends_on = [azurerm_storage_account.example]  # Ensure storage account is created first
}

# Log Analytics Workspace Resource - only create if it doesn't already exist
resource "azurerm_log_analytics_workspace" "example" {
  count                    = length(data.azurerm_log_analytics_workspace.existing.id) == 0 ? 1 : 0
  name                     = var.log_analytics_workspace_name
  location                 = var.location
  resource_group_name      = azurerm_resource_group.example[0].name
  sku                      = var.log_analytics_sku
  depends_on = [azurerm_resource_group.example]  # Ensure resource group is created first
}

# Monitor Diagnostic Setting Resource for AKS
resource "azurerm_monitor_diagnostic_setting" "example" {
  count                    = length(data.azurerm_kubernetes_cluster.existing.id) == 0 ? 1 : 0
  name                      = var.diagnostic_setting_name
  target_resource_id        = "/subscriptions/${var.azure_subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.ContainerService/managedClusters/${var.aks_name}"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.example[0].id

  metric {
    category = "AllMetrics"
    enabled  = true
  }
  
  depends_on = [azurerm_kubernetes_cluster.example]  # Ensure AKS is created first
}

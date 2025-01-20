# Provider configuration for Azure
provider "azurerm" {
  features {}
  client_id       = var.azure_client_id
  client_secret   = var.azure_client_secret
  tenant_id       = var.azure_tenant_id
  subscription_id = var.azure_subscription_id
}

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

# Resource group
resource "azurerm_resource_group" "example" {
  name     = var.resource_group_name
  location = var.location
}

# Azure Kubernetes Service Cluster
resource "azurerm_kubernetes_cluster" "example" {
  name                = var.aks_name
  location            = var.location
  resource_group_name = azurerm_resource_group.example.name
  dns_prefix          = "aks-cluster"

  default_node_pool {
    name       = "default"
    node_count = var.node_count
    vm_size    = "Standard_DS2_v2"
  }

  identity {
    type = "SystemAssigned"
  }
}

# Output kubeconfig (sensitive)
output "kubeconfig" {
  value     = azurerm_kubernetes_cluster.example.kube_config
  sensitive = true
}

resource "random_id" "unique_suffix" {
  byte_length = 8
}

resource "azurerm_storage_account" "example" {
  name                     = var.storage_account_name
  resource_group_name       = var.resource_group_name
  location                 = var.location
  account_tier              = "Standard"
  account_replication_type = "LRS"
}

# Storage Container Resource
resource "azurerm_storage_container" "example" {
  name                  = var.container_name
  storage_account_id    = azurerm_storage_account.example.id
  container_access_type = "private"
}

# Log Analytics Workspace Resource
resource "azurerm_log_analytics_workspace" "example" {
  name                = var.log_analytics_workspace_name
  location            = var.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
}

# Monitor Diagnostic Setting Resource
resource "azurerm_monitor_diagnostic_setting" "aks_metrics" {
  name               = "aks-metrics-setting"
  target_resource_id = "/subscriptions/${var.azure_subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.ContainerService/managedClusters/${var.aks_name}"

  metric {
    category = "AllMetrics"
    enabled  = true
}
log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
}

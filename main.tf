provider "azurerm" {
  features {}
  client_id       = var.azure_client_id
  client_secret   = var.azure_client_secret
  tenant_id       = var.azure_tenant_id
  subscription_id = var.azure_subscription_id
}

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
  location = var.location
}

# Create the AKS cluster
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

# Create the Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "example" {
  name                = "goreg-test-analytics-workspace2"
  location            = var.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
}

# Create the diagnostic settings for monitoring
resource "azurerm_monitor_diagnostic_setting" "aks_metrics" {
  name               = "aks-metrics-diagnostic-setting"
  target_resource_id = azurerm_kubernetes_cluster.example.id

  metric {
    category = "AllMetrics"
    enabled  = true
  }

  log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
}

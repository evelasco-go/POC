provider "azurerm" {
  features {}
  client_id       = var.azure_client_id
  client_secret   = var.azure_client_secret
  tenant_id       = var.azure_tenant_id
  subscription_id = var.azure_subscription_id
}

provider "random" {}

variable "azure_subscription_id" {}
variable "azure_client_id" {}
variable "azure_client_secret" {}
variable "azure_tenant_id" {}
variable "resource_group_name" {}
variable "aks_name" {}
variable "location" {}
variable "log_analytics_workspace_name" {}
variable "grafana_instance_name" {}

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
    node_count = 2
    vm_size    = "Standard_DS2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  addon_profiles {
    monitoring {
      enabled = true
      config {
        log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
      }
    }

    managed_prometheus {
      enabled = true
    }

    grafana {
      enabled = true
    }
  }
}

# Managed Grafana instance
resource "azurerm_monitor_grafana" "example" {
  name                = var.grafana_instance_name
  location            = var.location
  resource_group_name = azurerm_resource_group.example.name
  identity {
    type = "SystemAssigned"
  }
}

# Log Analytics Workspace Resource
resource "azurerm_log_analytics_workspace" "example" {
  name                = var.log_analytics_workspace_name
  location            = var.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
}

# Monitor Diagnostic Setting Resource for AKS
resource "azurerm_monitor_diagnostic_setting" "example" {
  name               = "aks-diagnostics"
  target_resource_id = "/subscriptions/${var.azure_subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.ContainerService/managedClusters/${var.aks_name}"

  metric {
    category = "AllMetrics"
    enabled  = true
  }

  log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
}

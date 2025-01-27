provider "azurerm" {
  features {}
  client_id       = "9a7b7fdd-5a88-46e3-8d9b-b78042012e30"
  client_secret   = "s6h8Q~WNY_QKu92SobDd7FnfSIWJsYSYmKeF2dw0"
  tenant_id       = "fd3a4a13-0cd8-4c1c-ba4c-e4995f5ee282"
  subscription_id = "15e60859-88d7-4c84-943f-55488479910c"
}

# Define variables
variable "azure_subscription_id" {
  default = "15e60859-88d7-4c84-943f-55488479910c"
}

variable "azure_client_id" {
  default = "9a7b7fdd-5a88-46e3-8d9b-b78042012e30"
}

variable "azure_client_secret" {
  default = "s6h8Q~WNY_QKu92SobDd7FnfSIWJsYSYmKeF2dw0"
}

variable "azure_tenant_id" {
  default = "fd3a4a13-0cd8-4c1c-ba4c-e4995f5ee282"
}

variable "resource_group_name" {
  default = "Goreg4"
}

variable "storage_account_name" {
  default = "goreg4"
}

variable "container_name" {
  default = "goreg4container"
}

variable "aks_name" {
  default = "goreg4-aks"
}

variable "log_analytics_workspace_name" {
  default = "goreg4-analytics"
}

variable "diagnostic_setting_name" {
  default = "goreg4-diagnostics"
}

variable "location" {
  default = "East US"
}

variable "log_analytics_sku" {
  default = "PerGB2018"
}

variable "node_count" {
  default = 2
}

# Resource group
resource "azurerm_resource_group" "example" {
  name     = var.resource_group_name
  location = var.location
}

# Azure Storage Account
resource "azurerm_storage_account" "example" {
  name                     = var.storage_account_name
  resource_group_name       = azurerm_resource_group.example.name
  location                 = var.location
  account_tier              = "Standard"
  account_replication_type = "LRS"
}

# Storage Container Resource
resource "azurerm_storage_container" "example" {
  name                  = var.container_name
  storage_account_name  = azurerm_storage_account.example.name
  container_access_type = "private"
}

# Azure Kubernetes Service (AKS) Cluster
resource "azurerm_kubernetes_cluster" "example" {
  name                = var.aks_name
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  default_node_pool {
    name       = "default"
    node_count = var.node_count
    vm_size    = "Standard_DS2_v2"
  }

  identity {
    type = "SystemAssigned"
  }
}

# Kubernetes Namespace (Monitoring)
resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "example" {
  name                = var.log_analytics_workspace_name
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = var.log_analytics_sku
}

# Diagnostic Setting for AKS
resource "azurerm_monitor_diagnostic_setting" "aks_metrics" {
  name               = var.diagnostic_setting_name
  target_resource_id = azurerm_kubernetes_cluster.example.id
  log_analytics {
    workspace_id = azurerm_log_analytics_workspace.example.id
  }

  metrics {
    category = "AllMetrics"
    enabled  = true
  }
}

# Helm Chart Installation (Prometheus & Grafana)
resource "helm_release" "prometheus" {
  name       = "prometheus"
  namespace  = "monitoring"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "15.1.0"
  wait       = true
}

resource "helm_release" "grafana" {
  name       = "grafana"
  namespace  = "monitoring"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  version    = "6.19.3"
  values     = [
    "adminPassword=yourpassword",
    "service.type=LoadBalancer"
  ]
  wait       = true
}

# Kubernetes ConfigMap (for monitoring)
resource "kubernetes_config_map" "prometheus_config" {
  metadata {
    name      = "prometheus-config"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
  }

  data = {
    "prometheus.yml" = <<YAML
# Configuration for Prometheus server
global:
  scrape_interval: 15s
scrape_configs:
  - job_name: 'kubernetes-pods'
    kubernetes_sd_configs:
      - role: pod
    relabel_configs:
      - source_labels: [__meta_kubernetes_pod_label_app]
        action: keep
        regex: prometheus
YAML
  }
}

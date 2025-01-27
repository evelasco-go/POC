provider "azurerm" {
  features {}
  client_id       = var.azure_client_id
  client_secret   = var.azure_client_secret
  tenant_id       = var.azure_tenant_id
  subscription_id = var.azure_subscription_id
}

# Define variables
variable "azure_subscription_id" {}
variable "azure_client_id" {}
variable "azure_client_secret" {}
variable "azure_tenant_id" {}
variable "resource_group_name" {}
variable "storage_account_name" {}
variable "container_name" {}
variable "aks_name" {}
variable "log_analytics_workspace_name" {}
variable "diagnostic_setting_name" {}

# Resource group
resource "azurerm_resource_group" "example" {
  name     = var.resource_group_name
  location = "East US"
}

# Azure Storage Account
resource "azurerm_storage_account" "example" {
  name                     = var.storage_account_name
  resource_group_name       = azurerm_resource_group.example.name
  location                 = "East US"
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
    node_count = 2
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
  sku                 = "PerGB2018"
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


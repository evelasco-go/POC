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
    helm = {
      source = "hashicorp/helm"
      version = "~> 2.0"
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

# Provider configuration for Helm
provider "helm" {
  kubernetes {
    host                   = azurerm_kubernetes_cluster.example.kube_config[0].host
    cluster_ca_certificate = azurerm_kubernetes_cluster.example.kube_config[0].cluster_ca_certificate
    client_certificate     = azurerm_kubernetes_cluster.example.kube_config[0].client_certificate
    client_key             = azurerm_kubernetes_cluster.example.kube_config[0].client_key
  }
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

# Azure Storage Account
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
  storage_account_name  = var.storage_account_name
  container_access_type = "private"
  lifecycle {
    prevent_destroy = true
  }
}

# Log Analytics Workspace Resource
resource "azurerm_log_analytics_workspace" "example" {
  name                = var.log_analytics_workspace_name
  location            = var.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = var.log_analytics_sku
}

# Monitor Diagnostic Setting Resource for AKS
resource "azurerm_monitor_diagnostic_setting" "example" {
  name               = var.diagnostic_setting_name
  target_resource_id = "/subscriptions/${var.azure_subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.ContainerService/managedClusters/${var.aks_name}"

  metric {
    category = "AllMetrics"
    enabled  = true
  }

  log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
}

# Create namespace for monitoring (optional)
resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

# Install Prometheus and Grafana using Helm (with kube-prometheus-stack)
resource "helm_release" "prometheus" {
  name       = "prometheus"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "45.3.0"

  set {
    name  = "prometheus.enabled"
    value = "true"
  }

  set {
    name  = "grafana.enabled"
    value = "true"
  }
}

# Optionally, install Grafana separately (this is redundant if using the kube-prometheus-stack chart)
resource "helm_release" "grafana" {
  name       = "grafana"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  version    = "6.10.1"

  set {
    name  = "adminPassword"
    value = "admin"
  }
}

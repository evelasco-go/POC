# Azure Provider Configuration
provider "azurerm" {
  features {}
  client_id       = var.azure_client_id
  client_secret   = var.azure_client_secret
  tenant_id       = var.azure_tenant_id
  subscription_id = var.azure_subscription_id
}

# Kubernetes Provider Configuration
provider "kubernetes" {
  config_path = "kubeconfig"
}

# Resource Group (must exist before other resources)
resource "azurerm_resource_group" "example" {
  name     = var.resource_group_name
  location = var.location
}

# Log Analytics Workspace (for Insights)
resource "azurerm_log_analytics_workspace" "example" {
  name                = "goreg4-analytics"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
}

# AKS Cluster (basic, without extra networking resources)
resource "azurerm_kubernetes_cluster" "example" {
  name                = var.aks_name
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  default_node_pool {
    name            = "default"
    node_count      = var.node_count
    vm_size         = "Standard_DS2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  dns_prefix = "${var.aks_name}-dns"
}

# Enable Insights (Diagnostic Setting for AKS)
resource "azurerm_monitor_diagnostic_setting" "example" {
  name                       = "goreg4-aks-diagnostics"
  target_resource_id         = azurerm_kubernetes_cluster.example.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id

  logs {
    category = "KubeCluster"
    enabled  = true
    retention_policy {
      days    = 30
      enabled = true
    }
  }

  metrics {
    category = "AllMetrics"
    enabled  = true
    retention_policy {
      days    = 30
      enabled = true
    }
  }
}

# Helm Chart Installation (Prometheus)
resource "helm_release" "prometheus" {
  depends_on = [azurerm_kubernetes_cluster.example]

  name       = "prometheus"
  namespace  = "monitoring"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "15.1.0"
  wait       = true
}

# Helm Chart Installation (Grafana)
resource "helm_release" "grafana" {
  depends_on = [azurerm_kubernetes_cluster.example]

  name       = "grafana"
  namespace  = "monitoring"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  version    = "6.19.3"
  values = [
    <<EOF
adminPassword: yourpassword
service:
  type: LoadBalancer
EOF
  ]
  wait       = true
}

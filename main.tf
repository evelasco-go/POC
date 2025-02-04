

# ✅ Enable Azure Monitor Managed Prometheus on AKS
resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "goreg4aks"

  default_node_pool {
    name       = "default"
    node_count = 2
    vm_size    = "Standard_D2s_v3"
  }

  identity {
    type = "SystemAssigned"
  }

  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.monitor.id
  }

  azure_monitor_metrics {
    enabled = true
  }
}

# ✅ Create a Log Analytics Workspace for Monitoring
resource "azurerm_log_analytics_workspace" "monitor" {
  name                = "goreg4-monitor-workspace"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# ✅ Create a Data Collection Rule (DCR) for Prometheus Metrics
resource "azurerm_monitor_data_collection_rule" "prometheus_dcr" {
  name                = var.dcr_name
  location            = var.location
  resource_group_name = var.resource_group_name

  destinations {
    azure_monitor_metrics {
      name = "prometheus-metrics"
    }
  }

  data_flow {
    streams      = ["Microsoft-PrometheusMetrics"]
    destinations = ["prometheus-metrics"]
  }
}

# ✅ Attach the DCR to the AKS Cluster
resource "azurerm_monitor_data_collection_rule_association" "aks_dcr_association" {
  name                    = "aks-prometheus-dcr"
  target_resource_id      = azurerm_kubernetes_cluster.aks.id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.prometheus_dcr.id
}

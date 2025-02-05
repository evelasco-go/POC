variable "dcr_name" {
  description = "The name of the Data Collection Rule"
  type        = string
  default     = "PrometheusDCR"
}

# ✅ Create a Log Analytics Workspace for Monitoring
resource "azurerm_log_analytics_workspace" "workspace" {
  name                = "goreg4-monitor-workspace"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# ✅ Deploy AKS Cluster
resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "aks"

  default_node_pool {
    name       = "default"
    node_count = var.node_count
    vm_size    = "Standard_DS2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  # ✅ Enable Container Insights (OMS Agent)
  addon_profile {
    oms_agent {
      enabled                    = true
      log_analytics_workspace_id = azurerm_log_analytics_workspace.workspace.id
    }
  }
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

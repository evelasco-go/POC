# ✅ Provider Configuration for Azure
provider "azurerm" {
  features {}
  client_id       = var.azure_client_id
  client_secret   = var.azure_client_secret
  tenant_id       = var.azure_tenant_id
  subscription_id = var.azure_subscription_id
}

# ✅ Create a Data Collection Rule (DCR) for Prometheus Metrics
resource "azurerm_monitor_data_collection_rule" "prometheus_dcr" {
  name                = "PrometheusDCR"
  location            = var.location
  resource_group_name = var.resource_group_name
  kind                = "Linux"  # ✅ Required for Prometheus

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

# ✅ Attach the DCR to the Existing AKS Cluster
resource "azurerm_monitor_data_collection_rule_association" "aks_dcr_association" {
  name                    = "aks-prometheus-dcr"
  target_resource_id      = "/subscriptions/${var.azure_subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.ContainerService/managedClusters/${var.aks_name}"
  data_collection_rule_id = azurerm_monitor_data_collection_rule.prometheus_dcr.id
}

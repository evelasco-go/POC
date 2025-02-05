# ✅ Provider Configuration for Azure
provider "azurerm" {
  features {}
  client_id       = var.azure_client_id
  client_secret   = var.azure_client_secret
  tenant_id       = var.azure_tenant_id
  subscription_id = var.azure_subscription_id
}

resource "azurerm_monitor_data_collection_rule" "prometheus_dcr" {
  name                = "PrometheusDCR"
  location            = var.location
  resource_group_name = var.resource_group_name
  kind                = "Linux"  # Ensure this matches your AKS environment

  destinations {
    azure_monitor_metrics {
      name = "prometheus-metrics"
    }
  }

  data_flow {
    streams      = ["Microsoft-PrometheusMetrics"]
    destinations = ["prometheus-metrics"]
  }

  data_sources {
    performance_counter {
      name                          = "prometheus-metrics-source"
      streams                       = ["Microsoft-PrometheusMetrics"]
      sampling_frequency_in_seconds = 60  # ✅ Required field added
      counter_specifiers = [
        "\\Prometheus(*,*)\\*"
      ]
    }
  }
}


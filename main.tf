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

  # Define the data sources (Prometheus)
  data_sources {
    prometheus_scraper {
      scrape_url = "http://your-prometheus-server:9090"  # Replace with your Prometheus server URL
    }
  }

  # Define destinations for metrics collection
  destinations {
    azure_monitor_metrics {
      name = "prometheus-metrics"
    }
  }

  # Define data flow from Prometheus to Azure Monitor
  data_flow {
    streams      = ["Microsoft-PrometheusMetrics"]
    destinations = ["prometheus-metrics"]
  }
}

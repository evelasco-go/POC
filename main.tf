provider "azurerm" {
  features {}
  subscription_id = "15e60859-88d7-4c84-943f-55488479910c"
  client_id       = "9a7b7fdd-5a88-46e3-8d9b-b78042012e30"
  client_secret   = "s6h8Q~WNY_QKu92SobDd7FnfSIWJsYSYmKeF2dw0"
  tenant_id       = "fd3a4a13-0cd8-4c1c-ba4c-e4995f5ee282"
}

provider "kubernetes" {
  config_path = "~/.kube/config"  # Adjust if necessary
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"  # Adjust if necessary
  }
}

resource "azurerm_resource_group" "example" {
  name     = "Goreg4"
  location = "East US"
}

resource "azurerm_storage_account" "example" {
  name                     = "goreg4"
  resource_group_name       = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier              = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "example" {
  name                   = "goreg4container"
  storage_account_id     = azurerm_storage_account.example.id  # Use ID instead of name
  container_access_type  = "private"
}

resource "azurerm_monitor_diagnostic_setting" "aks_metrics" {
  name                       = "goreg4-diagnostics"
  target_resource_id         = azurerm_kubernetes_cluster.example.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
  metric {
    category = "AllMetrics"
    enabled  = true
  }
  #log_analytics {
  #  category = "KubeInventory"
  #  enabled  = true
  #}
}

resource "azurerm_kubernetes_cluster" "example" {
  name                = "goreg4-aks"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  dns_prefix          = "goreg4"
  linux_profile {
    admin_username = "azureuser"
    ssh_key {
      key_data = "ssh-rsa ... your SSH key ...="
    }
  }
  default_node_pool {
    name       = "default"
    node_count = 2
    vm_size    = "Standard_DS2_v2"
  }
}

resource "helm_release" "prometheus" {
  name       = "prometheus"
  namespace  = "monitoring"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "40.0.0"
  values = [
    {
      "prometheus" = {
        "service" = {
          "type" = "LoadBalancer"
        }
      }
    }
  ]
  wait       = true
}

resource "helm_release" "grafana" {
  name       = "grafana"
  namespace  = "monitoring"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  version    = "6.19.3"
  values = [
    {
      "adminPassword" = "yourpassword"
    }
  ]
  wait       = true
}

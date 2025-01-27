# Azure Provider Configuration
provider "azurerm" {
  features {}
  client_id       = var.azure_client_id
  client_secret   = var.azure_client_secret
  tenant_id       = var.azure_tenant_id
  subscription_id = var.azure_subscription_id
}

# Resource Group
resource "azurerm_resource_group" "example" {
  name     = var.resource_group_name
  location = var.location
}

# Azure Storage Account
resource "azurerm_storage_account" "example" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.example.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Storage Container
resource "azurerm_storage_container" "example" {
  name                  = var.container_name
  storage_account_name  = azurerm_storage_account.example.name
  container_access_type = "private"
}

# Virtual Network
resource "azurerm_virtual_network" "example" {
  name                = "${var.resource_group_name}-vnet"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.0.0.0/16"]
}

# Subnet for AKS
resource "azurerm_subnet" "example" {
  name                 = "${var.resource_group_name}-subnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

# AKS Cluster
resource "azurerm_kubernetes_cluster" "example" {
  name                = var.aks_name
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  default_node_pool {
    name                       = "default"
    temporary_name_for_rotation = "default-rotated" # Temporary name for rotation
    node_count                 = var.node_count
    vm_size                    = "Standard_DS2_v2"
    vnet_subnet_id             = azurerm_subnet.example.id
  }

  identity {
    type = "SystemAssigned"
  }

  dns_prefix = "${var.aks_name}-dns"
}

# Role Assignment for AKS
resource "azurerm_role_assignment" "example" {
  principal_id         = azurerm_kubernetes_cluster.example.kubelet_identity[0].object_id
  role_definition_name = "Contributor"
  scope                = azurerm_resource_group.example.id
}

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "example" {
  name                = var.log_analytics_workspace_name
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = var.log_analytics_sku
}

# Diagnostic Settings for AKS
resource "azurerm_monitor_diagnostic_setting" "aks_metrics" {
  name               = var.diagnostic_setting_name
  target_resource_id = azurerm_kubernetes_cluster.example.id

  metric {
    category = "AllMetrics"
    enabled  = true
  }

  log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
}

# Fetch AKS Credentials
resource "null_resource" "get_aks_credentials" {
  provisioner "local-exec" {
    command = <<EOT
      az aks get-credentials --resource-group ${var.resource_group_name} --name ${var.aks_name} --admin --overwrite-existing
    EOT
  }

  triggers = {
    always_run = timestamp()
  }
}

# Helm Release for Prometheus
resource "helm_release" "prometheus" {
  depends_on = [null_resource.get_aks_credentials]

  name       = "prometheus"
  namespace  = "monitoring"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "15.1.0"
  wait       = true
}

# Helm Release for Grafana
resource "helm_release" "grafana" {
  depends_on = [null_resource.get_aks_credentials]

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

# Output Values
output "aks_cluster_name" {
  value = azurerm_kubernetes_cluster.example.name
}

output "grafana_url" {
  value = "Grafana installed at LoadBalancer. Check the external IP in your Kubernetes cluster."
}

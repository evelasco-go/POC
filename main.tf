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
  config_path = "${path.module}/kubeconfig"
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

# Storage Container Resource
resource "azurerm_storage_container" "example" {
  name                 = var.container_name
  storage_account_id   = azurerm_storage_account.example.id
  container_access_type = "private"
}

# Virtual Network (Imported Resource)
resource "azurerm_virtual_network" "example" {
  # Replace with imported resource information
}

# Subnet (Imported Resource)
resource "azurerm_subnet" "example" {
  # Replace with imported resource information
}

# Azure Kubernetes Service (AKS) Cluster
resource "azurerm_kubernetes_cluster" "example" {
  name                = var.aks_name
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  default_node_pool {
    name            = "default"
    node_count      = var.node_count
    vm_size         = "Standard_DS2_v2"
    vnet_subnet_id  = azurerm_subnet.example.id
  }

  identity {
    type = "SystemAssigned"
  }

  dns_prefix = "${var.aks_name}-dns"
}

# Fetch AKS Credentials
resource "null_resource" "get_aks_credentials" {
  provisioner "local-exec" {
    command = <<EOT
      az aks get-credentials --resource-group ${azurerm_resource_group.example.name} --name ${var.aks_name} --file kubeconfig
    EOT
  }

  triggers = {
    always_run = "${timestamp()}"
  }
}

# Helm Chart Installation (Prometheus)
resource "helm_release" "prometheus" {
  depends_on = [null_resource.get_aks_credentials]

  name       = "prometheus"
  namespace  = "monitoring"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "15.1.0"
  wait       = true
}

# Helm Chart Installation (Grafana)
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

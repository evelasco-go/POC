# Providers
provider "azurerm" {
  features {}
  client_id       = var.azure_client_id
  client_secret   = var.azure_client_secret
  tenant_id       = var.azure_tenant_id
  subscription_id = var.azure_subscription_id
}

provider "kubernetes" {
   config_path = var.kubeconfig_path
}

# Helm Chart Installation - Prometheus
resource "helm_release" "prometheus" {
  name       = "prometheus"
  namespace  = "monitoring"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "45.8.0" # Adjust as needed
  wait       = true
}

# Helm Chart Installation - Grafana
resource "helm_release" "grafana" {
  name       = "grafana"
  namespace  = "monitoring"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  version    = "6.57.4" # Adjust as needed
  values = [
    <<EOF
adminPassword: "yourpassword"
service:
  type: LoadBalancer
EOF
  ]
  wait       = true
}

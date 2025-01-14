# Declare the Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "example" {
  name                = "goreg-test-analytics-workspace2"  # Name of the new workspace
  location            = "East US"                          # Location for the workspace
  resource_group_name = "POCMyResourceGroup"              # Resource group for the workspace
  sku                 = "PerGB2018"                       # SKU for the workspace
}

# Declare a new Diagnostic Setting for AKS monitoring
resource "azurerm_monitor_diagnostic_setting" "aks_monitoring" {
  name               = "aks-diagnostic-setting"            # Name of the diagnostic setting
  target_resource_id = azurerm_kubernetes_cluster.example.id  # AKS cluster ID

  # Enable metric collection
  metric {
    category = "AllMetrics"  # You can specify specific categories like "ContainerInsights" or "KubeControllerManager"
    enabled  = true
  }

  # Enable log collection
  log {
    category = "AuditLogs"    # Choose the appropriate log category for AKS
    enabled  = true
  }

  log_analytics_workspace_id     = azurerm_log_analytics_workspace.example.id  # Log Analytics Workspace ID
  log_analytics_destination_type = "Dedicated"  # This specifies where the logs will go (Dedicated workspace)
}

# Declare the Storage Account (for storing Terraform state)
resource "azurerm_storage_account" "example" {
  name                     = "pocmystorageacct123"         # Storage account name
  resource_group_name      = "POCMyResourceGroup"           # Resource group for the storage account
  location                 = "East US"                      # Location for the storage account
  account_tier              = "Standard"                    # Account tier for storage account
  account_replication_type = "LRS"                          # Replication type for the storage account
}

# Declare the Storage Container for Terraform state
resource "azurerm_storage_container" "example" {
  name                  = "tfstate"                      # Container name
  storage_account_name  = azurerm_storage_account.example.name  # Link the storage account
  container_access_type = "private"                         # Container access type
}

# Declare AKS Cluster
resource "azurerm_kubernetes_cluster" "example" {
  name                = "MyAKSCluster"                   # AKS Cluster name
  location            = "East US"                         # Location for the AKS cluster
  resource_group_name = "POCMyResourceGroup"             # Resource group for the AKS cluster
  dns_prefix          = "exampleaks"                     # DNS prefix for the cluster
  default_node_pool {
    name       = "default"
    node_count = 3
    vm_size    = "Standard_DS2_v2"
  }

  # Add other AKS configuration as required
}

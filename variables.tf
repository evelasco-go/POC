variable "azure_client_id" {}
variable "azure_client_secret" {}
variable "azure_tenant_id" {}
variable "azure_subscription_id" {}
variable "resource_group_name" {}
variable "location" { default = "eastus" }
variable "aks_name" {}
variable "node_count" { default = 2 }
variable "storage_account_name" {}
variable "container_name" {}
variable "log_analytics_workspace_name" {}
variable "log_analytics_sku" { default = "PerGB2018" }
variable "diagnostic_setting_name" {}

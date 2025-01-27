variable "azure_subscription_id" {
  description = "The Azure subscription ID"
  default = "15e60859-88d7-4c84-943f-55488479910c"
}

variable "azure_client_id" {
  description = "The Azure client ID"
  default = "9a7b7fdd-5a88-46e3-8d9b-b78042012e30"
}

variable "azure_client_secret" {
  description = "The Azure client secret"
  default = "s6h8Q~WNY_QKu92SobDd7FnfSIWJsYSYmKeF2dw0"
}

variable "azure_tenant_id" {
  description = "The Azure tenant ID"
  default = "fd3a4a13-0cd8-4c1c-ba4c-e4995f5ee282"
}

variable "resource_group_name" {
  description = "The name of the Azure resource group"
  default = "Goreg4"
}

variable "storage_account_name" {
  description = "The name of the storage account"
  default = "goreg4"
}

variable "container_name" {
  description = "The name of the storage container"
  default = "goreg4container"
}

variable "aks_name" {
  description = "The name of the AKS cluster"
  default = "goreg4-aks"
}

variable "log_analytics_workspace_name" {
  description = "The name of the Log Analytics workspace"
  default = "goreg4-analytics"
}

variable "diagnostic_setting_name" {
  description = "The name of the diagnostic setting"
  default = "goreg4-diagnostics"
}

variable "location" {
  description = "The Azure region"
  default = "East US"
}

variable "log_analytics_sku" {
  description = "The Log Analytics SKU"
  default = "PerGB2018"
}

variable "node_count" {
  description = "The number of AKS nodes"
  default = 2
}

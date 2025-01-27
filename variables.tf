variable "azure_subscription_id" {}
variable "azure_client_id" {}
variable "azure_client_secret" {}
variable "azure_tenant_id" {}
variable "resource_group_name" {
  default = "Goreg4"
}
variable "storage_account_name" {
  default = "goreg4"
}
variable "container_name" {
  default = "goreg4container"
}
variable "aks_name" {
  default = "POCAKSCluster"
}
variable "log_analytics_workspace_name" {
  default = "pocanalyticspcpcpoc"
}
variable "diagnostic_setting_name" {
  default = "pocdiagnosticpoc"
}

variable "azure_subscription" {
  description = "The Azure subscription name or ID"
  type        = string
}

variable "azure_subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "azure_client_id" {
  description = "Azure Client ID"
  type        = string
}

variable "azure_client_secret" {
  description = "Azure Client Secret"
  type        = string
}

variable "azure_tenant_id" {
  description = "Azure Tenant ID"
  type        = string
}

variable "RESOURCE_GROUP_NAME" {
  description = "Name of the Resource Group"
  type        = string
}

variable "STORAGE_ACCOUNT_NAME" {
  description = "Name of the Storage Account for Terraform State"
  type        = string
}

variable "CONTAINER_NAME" {
  description = "Name of the Storage Container for Terraform State"
  type        = string
}

variable "AKS_NAME" {
  description = "Name of the AKS Cluster"
  type        = string
}

variable "NODE_COUNT" {
  description = "Number of nodes in the AKS cluster"
  type        = number
}

variable "LOCATION" {
  description = "Azure location for the resources"
  type        = string
}

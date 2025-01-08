variable "AZURE_CLIENT_ID" {}
variable "AZURE_CLIENT_SECRET" {}
variable "AZURE_TENANT_ID" {}
variable "AZURE_SUBSCRIPTION_ID" {}

variable "resource_group_name" {
  default = "POCMyResourceGroup"
}

variable "location" {
  default = "East US"
}

variable "storage_account_name" {
  default = "pocmystorageacct123"
}

variable "container_name" {
  default = "tfstate"
}

variable "aks_name" {
  default = "MyAKSCluster"
}

variable "node_count" {
  default = 2
}

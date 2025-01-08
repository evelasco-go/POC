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

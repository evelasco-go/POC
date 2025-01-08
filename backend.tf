terraform {
  backend "azurerm" {
    resource_group_name  = "POCMyResourceGroup"
    storage_account_name = "pocmystorageacct123"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}

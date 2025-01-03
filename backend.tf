terraform {
  backend "azurerm" {
    resource_group_name  = "MyResourceGroup"
    storage_account_name = "mystorageacct123"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}

terraform {
  backend "azurerm" {
    resource_group_name  = "pcPOCresourcepcpcpcpoc"
    storage_account_name = "pcpocstoragepcpcpcpoc"
    container_name       = "pctfstate"
    key                  = "terraform.tfstate"
  }
}

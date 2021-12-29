# Configure min terraform version
terraform {
  required_version = ">=0.15.5"
}
# Initializing the module to connect to Azure
provider "azurerm" {
  skip_provider_registration = true
  features {}
}

# This will configure Terraform to store the state file in a Azure Storage, so it can be shared
# to everyone on the team. Please notice that we need to have separated storage for each environment we have (dev, qa, preprod, prod) for security reasons
terraform {
  backend "azurerm" {
    resource_group_name  = "uksouth-iflx-shar-qa-rg"
    storage_account_name = "infolexterraformstateqa"
    container_name       = "terraform-state"
    key                  = "terraform.tfstate.POC_ADO_PRO"
  }
}

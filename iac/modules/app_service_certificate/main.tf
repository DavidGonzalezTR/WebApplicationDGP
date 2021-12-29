resource "azurerm_app_service_certificate" "example" {
  name                = var.certificate_name
  resource_group_name = var.resource_group_name
  location            = var.resource_group_name_location
  key_vault_secret_id = var.keyvault_cert_secret_id
  tags = {
    "tr:application-asset-insight-id" = "202226"
  }
  //password            = "terraform"
}

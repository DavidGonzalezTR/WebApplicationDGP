data "azurerm_resource_group" "module_vnet_resource_group" {
  name = var.resource_group_name
}

resource "azurerm_virtual_network" "module_vnet" {
  name                = var.vnet_name
  address_space       = var.vnet_address_space
  location            = data.azurerm_resource_group.module_vnet_resource_group.location
  resource_group_name = var.resource_group_name
  dns_servers         = var.vnet_dns_servers
  tags = {
    "tr-financial-identifier" : "0000066497",
    "tr:application-asset-insight-id" : "205257",
    "tr:environment-type" : var.vnet_tag_env
  }
}

data "azurerm_resource_group" "module_subnet_resource_group" {
  name = var.resource_group_name
}

resource "azurerm_subnet" "module_subnet" {
  name                 = var.subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.vnet_name
  address_prefixes     = var.subnet_address_prefixes
  service_endpoints    = var.subnet_service_endpoints
  dynamic "delegation" {
    for_each = var.delegations
    content {
      name = delegation.value["name"]
      service_delegation {
        name    = delegation.value["service_delegation_name"]
        actions = delegation.value["actions"]
      }
    }
  }
}

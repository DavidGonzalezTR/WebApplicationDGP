output "vnet_name" {
  value       = azurerm_virtual_network.module_vnet.name
  description = "The Vnet Name"
}
output "vnet_rg_name" {
  value       = azurerm_virtual_network.module_vnet.resource_group_name
  description = "The resource Group of th Vnet "
}

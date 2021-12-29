output "service_name" {
  value       = azurerm_app_service.module_app_service.name
  description = "The app service plan ID"
}
output "resource_group_name" {
  value       = azurerm_app_service.module_app_service.resource_group_name
  description = "The app service plan ID"
}

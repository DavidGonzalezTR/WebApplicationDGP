output "app_service_plan_id" {
  value       = azurerm_app_service_plan.module_app_service_plan.id
  description = "The app service plan ID"
}

module "WebApplicationDGP_app_service_plan" {
  source = "../../modules/app_service_plan"
  # This means a consuption plan
  sku_tier            = "PremiumV2"
  sku_size            = "P1v2"
  resource_group_name = "uksouth-iflx-shar-dev-rg"
  environment         = "dev"
  service_name        = "uksouth-iflx-WebApplicationDGP-PRE-plan"
  kind                = "app"
  create_autoescale   = false
  #email_notification  = azurerm_monitor_action_group.module_azurerm_monitor_action_group.email_receiver[0].email_address
  #alert_action_group_id = azurerm_monitor_action_group.module_azurerm_monitor_action_group.id
}

module "WebApplicationDGP_app_service" {
  source                      = "../../modules/app_service"
  resource_group_name         = "uksouth-iflx-shar-dev-rg"
  environment                 = "dev"
  service_name                = "uksouth-iflx-shar-WebApplicationDGP-PRE-app"
  app_service_plan_id         = module.WebApplicationDGP_app_service_plan.app_service_plan_id
  use_ip_restrictions         = false
  scm_use_main_ip_restriction = false
  ftps_state                  = "AllAllowed"
  tls_version                 = local.tls_version
  subscriptionId              = local.subscriptionId
  client_affinity_enabled     = true
  health_check_path           = "/healthcheck"
  enabled_autoheal            = false
  create_alert                = false
  #alert_action_group_id       = azurerm_monitor_action_group.module_azurerm_monitor_action_group.id
  app_settings = {
          ANCM_ADDITIONAL_ERROR_PAGE_LINK                 = "https://uksouth-iflx-shar-WebApplicationDGP-dev-app.scm.azurewebsites.net/detectors?type=tools&name=eventviewer"
          
        }
  #Area Vnet Integration
  #   vnet_name = "VNet-PROD-westeurope"
  #   vnet_rg = "westeurope-service-group"
  #   subnet_name = "westeurope-iflx-pro-shar-rter-backend"
}

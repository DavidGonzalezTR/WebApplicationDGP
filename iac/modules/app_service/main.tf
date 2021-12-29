# Some "contants" we can change that will be applied to the whole script
# Those "constants" are defined to make it easier to change stuff in this script without much effort
locals {
  app_service_name     = var.service_name
  https_only           = false
  action_group_id_list = var.alert_action_group_id != null ? tomap({ key = var.alert_action_group_id }) : {}
  tags = {
    "tr:application-asset-insight-id" = "202226"
   
  }
}

# This local is here to make it easier to configure IP Restrictions in the app service, since it will be used in a loop
# inside the app service resource, which will be much easier to read
locals {
  ip_restrictions = [
    {
      ip_address = "159.220.0.0/16"
      rule_name  = "rule 1"
      priority   = 100
    },
    {
      ip_address = "84.18.160.0/19"
      rule_name  = "rule 2"
      priority   = 101
    }
  ]
  idents = [
    {
      type = "SystemAssigned"
    }
  ]

}

# I am referencing a already created resource group because I will need some properties from it
data "azurerm_resource_group" "module_app_service_rg" {
  name = var.resource_group_name
}
data "azurerm_virtual_network" "module_app_service_vnet" {
  count               = var.subnet_name != "" ? 1 : 0
  name                = var.vnet_name
  resource_group_name = var.vnet_rg
}

data "azurerm_subnet" "module_app_service_subnet" {
  count                = var.subnet_name != "" ? 1 : 0
  name                 = var.subnet_name
  virtual_network_name = data.azurerm_virtual_network.module_app_service_vnet[count.index].name
  resource_group_name  = data.azurerm_virtual_network.module_app_service_vnet[count.index].resource_group_name
}

# This will deploy an app service for the app service connected to the app service plan created above.
# Its name would be something likeiflx-app-service-plan-dev, iflx-app-service-plan-preprod, etc.
# depending on the environment we are working on
resource "azurerm_app_service" "module_app_service" {
  name = local.app_service_name
  # Going to deploy the service to the same location of the Resource Group
  location            = data.azurerm_resource_group.module_app_service_rg.location
  resource_group_name = var.resource_group_name
  # referencing the above app service plan we just created
  app_service_plan_id     = var.app_service_plan_id
  client_affinity_enabled = var.client_affinity_enabled
  https_only              = var.https_only
  dynamic "backup" {
    for_each = var.backup
    content {
      enabled             = backup.value.enabled
      name                = backup.value.name
      storage_account_url = backup.value.storage_account_url
      schedule {
        frequency_interval       = backup.value.schedule.frequency_interval
        frequency_unit           = backup.value.schedule.frequency_unit
        keep_at_least_one_backup = backup.value.schedule.keep_at_least_one_backup
        retention_period_in_days = backup.value.schedule.retention_period_in_days
        start_time               = backup.value.schedule.start_time
      }
    }

  }
  app_settings = var.app_settings

  dynamic "connection_string" {
    for_each = var.use_connection_string == false ? [] : [for conn in var.connection_string_list : {
      name  = conn.name
      type  = conn.type
      value = conn.value
    }]
    content {
      name  = connection_string.value.name
      type  = connection_string.value.type
      value = connection_string.value.value
    }
  }

  dynamic "identity" {
    for_each = var.use_identity == false ? [] : [for ident in local.idents : {
      type = ident.type
    }]

    content {
      type = identity.value.type

    }
  }
  site_config {
    dotnet_framework_version  = "v4.0"
    always_on                 = true
    ftps_state                = var.ftps_state
    use_32_bit_worker_process = var.use_32_bit_worker_process
    min_tls_version           = var.tls_version
    #health_check_path         = var.health_check_path
    dynamic "ip_restriction" {
      for_each = var.use_ip_restrictions == false ? [] : [for ip in local.ip_restrictions : {
        ip_address = ip.ip_address
        name       = ip.rule_name
        priority   = ip.priority
      }]

      content {
        ip_address = ip_restriction.value.ip_address
        priority   = ip_restriction.value.priority
        action     = "Allow"
        name       = ip_restriction.value.name
      }
    }
    default_documents = [
      "Default.htm",
      "Default.html",
      "Default.asp",
      "index.htm",
      "index.html",
      "iisstart.htm",
      "default.aspx",
      "index.php",
      "hostingstart.html",
    ]

    scm_use_main_ip_restriction = var.scm_use_main_ip_restriction

  }

  tags = merge(local.tags, var.tags)

  lifecycle {
    ignore_changes = [resource_group_name]
  }
}

resource "azurerm_app_service_virtual_network_swift_connection" "module_app_service_vnet_integration" {
  count          = var.subnet_name != "" ? 1 : 0
  app_service_id = azurerm_app_service.module_app_service.id
  subnet_id      = data.azurerm_subnet.module_app_service_subnet[count.index].id
}
### Activar el auto heal con azurerm más abajo esta con azure cli
# resource "null_resource" "module_app_service_auto_heal_enabled" {
#   count = var.enabled_autoheal == true ? 1 : 0
#   provisioner "local-exec" {
#     command     = "./AzureRM_autoheal_enabled.ps1 -subscriptionId ${var.subscriptionId} -webapp ${azurerm_app_service.module_app_service.name} -rg ${azurerm_app_service.module_app_service.resource_group_name}"
#     working_dir = "../../modules/app_service/scripts/"
#     interpreter = ["PowerShell"]
#   }
# }

### Activar el auto heal con azure cli pendiente de que permite añadir el path
# resource "null_resource" "module_app_service_auto_heal_enabled" {
#   count = var.enabled_autoheal == true ? 1 : 0 
#   provisioner "local-exec" {
#     command = "./Azcli_autoheal_enabled.ps1 -webapp ${azurerm_app_service.module_app_service.name} -rg ${azurerm_app_service.module_app_service.resource_group_name}"
#     working_dir = "../../modules/app_service/scripts/"
#     interpreter = ["PowerShell"]
#   }
# }

# resource "null_resource" "module_app_service_auto_heal_disabled" {
#   count = var.enabled_autoheal == false ? 1 : 0
#   provisioner "local-exec" {
#     command     = "./Azcli_autoheal_disabled.ps1 -webapp ${azurerm_app_service.module_app_service.name} -rg ${azurerm_app_service.module_app_service.resource_group_name}"
#     working_dir = "../../modules/app_service/scripts/"
#     interpreter = ["PowerShell"]
#   }
# }

resource "azurerm_monitor_metric_alert" "module_app_service_alert_availability" {
  count               = var.create_alert == true ? 1 : 0
  name                = "${var.service_name}-availability-alert"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_app_service.module_app_service.id]
  description         = "availability alert of ${var.service_name}"
  window_size         = "PT5M"
  frequency           = "PT1M"
  severity            = 3
  auto_mitigate       = true
  # health_check_evaluation_period = 5
  criteria {
    metric_namespace = "microsoft.web/sites"
    metric_name      = "HealthCheckStatus"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = 100

    # dimension {
    #   name     = "ApiName"
    #   operator = "Include"
    #   values   = ["*"]
    # }
  }
  tags = {
    "tr:application-asset-insight-id" = "202226"
  }
  dynamic "action" {
    for_each = local.action_group_id_list
    content {
      action_group_id = action.value
    }
  }

  lifecycle {
    ignore_changes = [resource_group_name]
  }
}

resource "azurerm_management_lock" "app_service_lock" {
  count      = var.environment == "pro" || var.prevent_destroy ? 1 : 0
  name       = "prevent_destroy"
  scope      = azurerm_app_service.module_app_service.id
  lock_level = "CanNotDelete"
  notes      = "Locked by a terraform script"
}

resource "null_resource" "module_app_service_webjob_deletetemps_enabled" {
  count = var.enabled_webjob_deletetemps == true ? 1 : 0
  provisioner "local-exec" {
    command     = "./AzureRM_create_webjob_deleteTemps_enabled.ps1 -subscriptionId ${var.subscriptionId} -webapp ${azurerm_app_service.module_app_service.name} -rg ${azurerm_app_service.module_app_service.resource_group_name}"
    working_dir = "../../modules/app_service/scripts/"
    interpreter = ["PowerShell"]
  }
}


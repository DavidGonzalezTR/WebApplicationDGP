# Some "contants" we can change that will be applied to the whole script
# Those "constants" are defined to make it easier to change stuff in this script without much effort
locals {
  app_service_autoscale_name  = format("%s-autoescale", lower(var.service_name))
  app_service_plan_name       = var.service_name
  scale_up_CPU_threshold      = var.scale_up_CPU_threshold      #85
  scale_down_CPU_threshold    = var.scale_down_CPU_threshold    #40
  scale_up_memory_threshold   = var.scale_up_memory_threshold   #85
  scale_down_memory_threshold = var.scale_down_memory_threshold #40
  tags = {
    "tr:application-asset-insight-id" = "202226"
   
  }
}

data "azurerm_resource_group" "module_app_service_plan_rg" {
  name = var.resource_group_name
}

# This will deploy an app service plan for the app service. Its name would be something like
# iflx-app-service-plan-dev, iflx-app-service-plan-preprod, etc. depending on the environment we are working on
resource "azurerm_app_service_plan" "module_app_service_plan" {
  name = local.app_service_plan_name
  # Going to deploy the service to the same location of the Resource Group
  location            = data.azurerm_resource_group.module_app_service_plan_rg.location
  resource_group_name = var.resource_group_name
  kind                = var.kind
  sku {
    tier     = var.sku_tier
    size     = var.sku_size
    capacity = null
  }
  tags = merge(local.tags, var.tags)
  lifecycle {
    ignore_changes = [sku.0.capacity, resource_group_name]
  }
}

# This is the part that will handle the Auto Scale feature
resource "azurerm_monitor_autoscale_setting" "module_app_service_autoscale" {
  name                = local.app_service_autoscale_name
  resource_group_name = var.resource_group_name
  # Going to deploy the service to the same location of the Resource Group
  location = data.azurerm_resource_group.module_app_service_plan_rg.location
  # referencing the above app service plan we just created
  target_resource_id = azurerm_app_service_plan.module_app_service_plan.id
  # When the tier is Dynamic (consuption plan), the app service cant have an auto scale.
  # Usefull when creating an azure function
  count = var.create_autoescale == true ? 1 : 0
  tags  = merge(local.tags, var.tags)

  # This part will configure a rule to scale the app service based on CPU usage
  profile {
    name = "defaultProfile"

    capacity {
      default = var.autoscale_default_num_instances
      minimum = var.autoscale_minimal_num_instances
      maximum = var.autoscale_max_num_instances
    }

    # Increase the Instance count by 1 when CPU usage is 85% consitanty for 5 mins
    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = azurerm_app_service_plan.module_app_service_plan.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = local.scale_up_CPU_threshold
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }

    # Decrease the Instance count by 1 when CPU usage is 40% or less consitanty for 5 mins
    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = azurerm_app_service_plan.module_app_service_plan.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = local.scale_down_CPU_threshold
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }

    # # Increase the Instance count by 1 when Memory usage is 85% consitanty for 5 mins
    rule {
      metric_trigger {
        metric_name        = "MemoryPercentage"
        metric_resource_id = azurerm_app_service_plan.module_app_service_plan.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = local.scale_up_memory_threshold
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }

    # Decrease the Instance count by 1 when Memory usage is 40% or less consitanty for 5 mins
    rule {
      metric_trigger {
        metric_name        = "MemoryPercentage"
        metric_resource_id = azurerm_app_service_plan.module_app_service_plan.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = local.scale_down_memory_threshold
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }

  }
  notification {
    email {
      send_to_subscription_administrator    = false
      send_to_subscription_co_administrator = false
      custom_emails                         = [var.email_notification]
    }
  }

  lifecycle {
    ignore_changes = [resource_group_name]
  }
}

resource "azurerm_monitor_metric_alert" "module_azure_app_service_monitor_cpu_alert" {
  count               = var.environment == "pro" ? 1 : 0
  name                = format("%s-CPU Percentage is Greater than 70", lower(var.service_name))
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_app_service_plan.module_app_service_plan.id]
  description         = "Action will be triggered when CPU is greater than 70."
  severity            = 2

  criteria {
    metric_namespace = "Microsoft.Web/serverfarms"
    metric_name      = "CPUPercentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 70

    dimension {
      name     = "Instance"
      operator = "Include"
      values   = ["*"]
    }
  }

  action {
    action_group_id = var.alert_action_group_id
  }

  tags = merge(local.tags, var.tags)

  lifecycle {
    ignore_changes = [resource_group_name]
  }
}

resource "azurerm_monitor_metric_alert" "module_azure_app_service_monitor_memory_alert" {
  count               = var.environment == "pro" ? 1 : 0
  name                = format("%s-Memory Percentage is Greater than 70", lower(var.service_name))
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_app_service_plan.module_app_service_plan.id]
  description         = "Action will be triggered when Memory is greater than 70."
  severity            = 2

  criteria {
    metric_namespace = "Microsoft.Web/serverfarms"
    metric_name      = "MemoryPercentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 70

    dimension {
      name     = "Instance"
      operator = "Include"
      values   = ["*"]
    }
  }

  action {
    action_group_id = var.alert_action_group_id
  }

  tags = merge(local.tags, var.tags)

  lifecycle {
    ignore_changes = [resource_group_name]
  }
}

resource "azurerm_management_lock" "app_service_plan_lock" {
  count      = var.environment == "pro" || var.prevent_destroy ? 1 : 0
  name       = "prevent_destroy"
  scope      = azurerm_app_service_plan.module_app_service_plan.id
  lock_level = "CanNotDelete"
  notes      = "Locked by a terraform script"
}

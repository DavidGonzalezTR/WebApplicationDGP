variable "resource_group_name" {
  description = "Resource group where the app service and the app service plan will be deployed to"
  type        = string
}

variable "environment" {
  description = "It can be lab, dev, qa, preprod or prod"
  type        = string
  default     = "dev"
  validation {
    condition     = contains(["lab", "dev", "qa", "pre", "pro"], var.environment)
    error_message = "Argument \"environment\" must be either \"lab\", \"dev\", \"qa\", \"preprod\", or \"prod\"."
  }
}

variable "service_name" {
  description = "Name of the main service that will run in the app service, for example Infolex, Lexnet, API, etc."
  type        = string
}

variable "app_service_plan_id" {
  description = "The app service plan to connect this app service to"
  type        = string
}

variable "use_ip_restrictions" {
  type    = bool
  default = true
}

variable "ftps_state" {
  type    = string
  default = "Disabled"
}

variable "scm_use_main_ip_restriction" {
  type    = bool
  default = false
}

variable "app_settings" {
  type    = map(any)
  default = null
}

variable "use_identity" {
  type    = bool
  default = false
}

variable "use_connection_string" {
  type    = bool
  default = false
}
variable "client_affinity_enabled" {
  type    = bool
  default = false
}
variable "connection_string_list" {
  type = list(object({
    name  = string
    type  = string
    value = string
  }))
  default = [
    {
      name  = "Conn"
      type  = "SQLServer"
      value = "sql"
    }
  ]
}
variable "vnet_name" {
  description = "sql Vnet name"
  type        = string
  default     = ""
}
variable "vnet_rg" {
  description = "sql Vnet ResourceGroup"
  type        = string
  default     = ""
}
variable "subnet_name" {
  description = "sql Subnet name"
  type        = string
  default     = ""
}

variable "tls_version" {
  description = "min_tls_version"
  type        = string
  default     = ""
}


variable "tags" {
  type    = map(any)
  default = null
}

variable "backup" {
  type = map(object({
    enabled             = bool
    name                = string
    storage_account_url = string
    schedule = object({
      frequency_interval       = number
      frequency_unit           = string
      keep_at_least_one_backup = bool
      retention_period_in_days = number
      start_time               = string
    })
  }))
  default = {}
}
variable "enabled_autoheal" {
  description = "Enabled autoheal"
  type        = bool
  default     = false
}
variable "subscriptionId" {
  description = "subscription Id"
  type        = string
}
variable "health_check_path" {
  description = "health check path"
  type        = string
  default     = null
}
variable "create_alert" {
  description = "create alert"
  type        = bool
  default     = false
}

variable "alert_action_group_id" {
  type    = string
  default = null
}

variable "disk_encryption_enabled" {
  type    = bool
  default = true
}
variable "use_32_bit_worker_process" {
  type    = bool
  default = true
}

variable "https_only" {
  type    = bool
  default = false
}

variable "prevent_destroy" {
  type    = bool
  default = false
}

variable "enabled_webjob_deletetemps" {
  description = "Enable webjob delete temp folder"
  type        = bool
  default     = false
}
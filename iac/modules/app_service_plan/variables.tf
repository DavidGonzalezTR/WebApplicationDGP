variable "environment" {
  description = "It can be lab, dev, qa, preprod or prod"
  type        = string
  default     = "dev"
  validation {
    condition     = contains(["lab", "dev", "qa", "pre", "pro"], var.environment)
    error_message = "Argument \"environment\" must be either \"lab\", \"dev\", \"qa\", \"pre\", or \"pro\"."
  }
}

variable "service_name" {
  description = "Name of the main service that will run in the app service, for example Infolex, Lexnet, API, etc."
  type        = string
}

variable "sku_tier" {
  description = "The tier for the app service plan to be created"
  type        = string
  default     = "Standard"
}

variable "sku_size" {
  description = "The size for the app service to be created"
  type        = string
  default     = "S1"
}

variable "resource_group_name" {
  description = "Resource group where the app service and the app service plan will be deployed to"
  type        = string
}

variable "autoscale_default_num_instances" {
  description = "Default number of instances for the auto scale configuration"
  default     = 2
  type        = number
}

variable "autoscale_minimal_num_instances" {
  description = "Minimal number of intances that the auto scale should respect despite its configuration"
  default     = 2
  type        = number
}

variable "autoscale_max_num_instances" {
  description = "Maximum number of instances that the auto scale can enable for this app service, despite of its configuration"
  default     = 10
  type        = number
}

variable "kind" {
  description = ""
  type        = string
  default     = "Windows"
}

variable "create_autoescale" {
  type    = bool
  default = true
}

variable "alert_action_group_id" {
  type    = string
  default = null
}
variable "tags" {
  type    = map(any)
  default = null
}
variable "email_notification" {
  type    = string
  default = null
}

variable "prevent_destroy" {
  type    = bool
  default = false
}
variable "scale_up_CPU_threshold" {
  description = "CPU threshold for auto scale to scale up 1 instance"
  default     = 85
  type        = number
}
variable "scale_down_CPU_threshold" {
  description = "CPU threshold for auto scale to scale down 1 instance"
  default     = 40
  type        = number
}

variable "scale_up_memory_threshold" {
  description = "Memory threshold for auto scale to scale up 1 instance"
  default     = 85
  type        = number
}
variable "scale_down_memory_threshold" {
  description = "Memory threshold for auto scale to scale down 1 instance"
  default     = 40
  type        = number
}

variable "resource_group_name" {
  description = "Resource group where the app service and the app service plan will be deployed to"
  type        = string
}

variable "vnet_name" {
  description = "name of the Subnet will be deployed to"
  type        = string
  default     = ""
}

variable "vnet_address_space" {
  description = "list of address_prefixes of the Subnet"
  type        = list(string)
}

variable "vnet_dns_servers" {
  description = "list of address_prefixes of the Subnet"
  type        = list(string)
}
variable "vnet_tag_env" {
  description = "tag for the Vnet enviroment"
  type        = string
  default     = ""
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

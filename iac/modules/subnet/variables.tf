variable "resource_group_name" {
  description = "Resource group where the app service and the app service plan will be deployed to"
  type        = string
}

variable "vnet_name" {
  description = "name of the Vnet associated to the Subnet"
  type        = string
}

variable "subnet_name" {
  description = "name of the Subnet will be deployed to"
  type        = string
}

variable "subnet_service_endpoints" {
  description = "list of service endpoints of the Subnet"
  type        = list(string)
}

variable "subnet_address_prefixes" {
  description = "list of address_prefixes of the Subnet"
  type        = list(string)
}

variable "delegations" {
  description = "Subnet delegations"
  type        = map(any)
  default     = {}
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

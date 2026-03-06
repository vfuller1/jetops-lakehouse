# fab-variables.tf
# Variables for Microsoft Fabric environment

variable "location" {
  description = "Azure region for Fabric resources"
  type        = string
  default     = "eastus"
}

variable "fab_resource_group_name" {
  description = "Name of the resource group for Fabric resources"
  type        = string
  default     = "fab-fabric-rg"
}

variable "fab_name_prefix" {
  description = "Prefix for all Fabric resources"
  type        = string
  default     = "fab-"
}

# Add more variables as needed

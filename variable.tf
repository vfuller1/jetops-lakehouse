# Admin username for Rycrawl test server
variable "rycrawl_admin_username" {
  description = "Admin username for the Rycrawl Windows Server VM"
  type        = string
  default     = "administrator"
}

# Admin password for Rycrawl test server
variable "rycrawl_admin_password" {
  description = "Admin password for the Rycrawl Windows Server VM"
  type        = string
  sensitive   = true
  default     = "Jesusch!1"
}
variable "resource_group_name" {
  description = "The name of the resource group for Aviator Core"
  type        = string
  default     = "rg-aviator-core-prod"
}

variable "location" {
  description = "The Azure region to deploy the Aviator Core foundation"
  type        = string
  default     = "eastus2" 
}

# UPDATED: Matches the Tenant ID from your portal screenshot
variable "tenant_id" {
  description = "The Azure Tenant ID for Entra ID authentication"
  type        = string
  default     = "3246f21f-4c75-481d-8284-80c8ce2b36d1" 
}

variable "aks_cluster_name" {
  description = "The name of the Aviator Core AKS cluster"
  type        = string
  default     = "aks-aviator-core"
}

variable "hub_vnet_name" {
  description = "Name of the hub virtual network"
  type        = string
  default     = "vnet-hub-aviator"
}

variable "spoke_vnet_name" {
  description = "Name of the spoke virtual network for workloads"
  type        = string
  default     = "vnet-spoke-aviator"
}

variable "sql_admin_password" {
  description = "The password for the SQL Server admin"
  type        = string
  sensitive   = true
  default     = "ChangeMe12345!" 
}

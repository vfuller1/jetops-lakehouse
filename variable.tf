# Admin username for Rycrawl test server
variable "rycrawl_admin_username" {
  description = "Admin username for the Rycrawl Windows Server VM"
  type        = string
  default     = "rycrawladmin"
}

# Admin password for Rycrawl test server
variable "rycrawl_admin_password" {
  description = "Admin password for the Rycrawl Windows Server VM"
  type        = string
  sensitive   = true
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
}

# Herbalife Lakehouse Dev Environment Variables
variable "herbalife_project" {
  description = "Project name for resource naming."
  default     = "herbalife"
}

variable "herbalife_environment" {
  description = "Environment name (dev, prod, etc.)."
  default     = "dev"
}

variable "herbalife_region" {
  description = "Azure region for deployment."
  default     = "eastus2"
}

variable "herbalife_resource_group_name" {
  description = "Resource group name for core resources."
  default     = "rg-herbalife-dev-core"
}

variable "herbalife_storage_account_name" {
  description = "Storage account name (no hyphens, lowercase, 24 chars max)."
  default     = "stherbalifedev001"
}

variable "herbalife_databricks_workspace_name" {
  description = "Databricks workspace name."
  default     = "databricks-herbalife-dev"
}

variable "herbalife_eventhub_namespace_name" {
  description = "Event Hub namespace name."
  default     = "evh-herbalife-dev"
}

variable "enable_herbalife_storage_role_assignment" {
  description = "Whether Terraform should create the optional Storage Blob Data Contributor assignment for the fixed principal."
  type        = bool
  default     = false
}

locals {
  herbalife_common_tags = {
    Project     = var.herbalife_project
    Environment = var.herbalife_environment
    ManagedBy   = "Terraform"
  }
}

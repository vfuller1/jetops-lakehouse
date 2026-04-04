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

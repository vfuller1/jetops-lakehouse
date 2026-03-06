# fab-main.tf
# Terraform entry point for Microsoft Fabric environment

terraform {
  required_version = ">= 1.0.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Step 2: Create Resource Group for Fabric
resource "azurerm_resource_group" "fabric" {
  name     = var.fab_resource_group_name
  location = var.location
}

# Step 3: Create Storage Account for Fabric (fab- prefix)
resource "azurerm_storage_account" "fabric" {
  name                     = "fabstorage${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.fabric.name
  location                 = azurerm_resource_group.fabric.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
  allow_blob_public_access = false
}

# Random string for unique storage account name
resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

# Add Fabric-specific resources here

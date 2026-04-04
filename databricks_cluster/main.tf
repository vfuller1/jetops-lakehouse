terraform {
  required_version = ">= 1.0.0"

  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = ">= 1.0.0"
    }
  }

  backend "azurerm" {
    resource_group_name   = "rg-jetops-terraform-state"
    storage_account_name  = "stjetopsstate001"
    container_name        = "tfstate"
    key                   = "databricks-cluster.tfstate"
  }
}

provider "databricks" {
  auth_type = "pat"
}

data "databricks_current_user" "me" {}

resource "databricks_cluster" "herbalife_single_node" {
  cluster_name                 = "herbalife-single-node"
  spark_version                = "16.4.x-scala2.12"
  node_type_id                 = "Standard_D8s_v3"
  autotermination_minutes      = 30
  driver_node_type_id          = "Standard_D8s_v3"
  runtime_engine               = "PHOTON"
  is_single_node               = true
  kind                         = "CLASSIC_PREVIEW"
  data_security_mode           = "SINGLE_USER"
  single_user_name             = data.databricks_current_user.me.user_name
  enable_elastic_disk          = true
  enable_local_disk_encryption = false
}

output "herbalife_databricks_cluster_id" {
  value = databricks_cluster.herbalife_single_node.id
}
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

resource "databricks_directory" "herbalife_workspace" {
  path = "/Shared/Herbalife"
}

resource "databricks_secret_scope" "herbalife_storage" {
  name                     = var.herbalife_databricks_secret_scope
  initial_manage_principal = "users"
}

resource "databricks_secret" "raw_sas_token" {
  scope        = databricks_secret_scope.herbalife_storage.name
  key          = var.herbalife_raw_sas_secret_key
  string_value = var.herbalife_raw_sas_token
}

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

resource "databricks_notebook" "configure_sas_access" {
  source = "${path.module}/../app/configure_sas_access.ipynb"
  path   = "${databricks_directory.herbalife_workspace.path}/configure_sas_access"
}

resource "databricks_job" "configure_sas_access" {
  name = "Herbalife Configure SAS Access"

  task {
    task_key            = "configure-sas-access"
    existing_cluster_id = databricks_cluster.herbalife_single_node.id

    notebook_task {
      notebook_path = databricks_notebook.configure_sas_access.path
      source        = "WORKSPACE"
    }
  }
}

output "herbalife_databricks_cluster_id" {
  value = databricks_cluster.herbalife_single_node.id
}

output "herbalife_databricks_notebook_path" {
  value = databricks_notebook.configure_sas_access.path
}

output "herbalife_databricks_job_url" {
  value = databricks_job.configure_sas_access.url
}

output "herbalife_databricks_secret_scope" {
  value = databricks_secret_scope.herbalife_storage.name
}
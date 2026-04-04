resource "databricks_cluster" "herbalife_single_node" {
  cluster_name            = "herbalife-single-node"
  spark_version           = "16.4.x-scala2.12"
  node_type_id            = "Standard_D8s_v3"
  autotermination_minutes = 30
  driver_node_type_id     = "Standard_D8s_v3"
  runtime_engine          = "PHOTON"
  is_single_node          = true
  kind                    = "CLASSIC_PREVIEW"
  enable_elastic_disk     = true
  enable_local_disk_encryption = false

  depends_on = [azurerm_databricks_workspace.HL_herbalife_dev]
}
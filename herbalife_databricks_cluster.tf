resource "databricks_cluster" "herbalife_single_node" {
    access_mode = "SINGLE_USER"
  cluster_name            = "herbalife-single-node"
  spark_version           = "16.4.x-scala2.12"
  node_type_id            = "Standard_D8s_v3"
  autotermination_minutes = 30
  num_workers             = 0 # Single node cluster
  
  # Optionally, you can add tags or other settings here
  # custom_tags = {
  #   environment = "dev"
  # }
}

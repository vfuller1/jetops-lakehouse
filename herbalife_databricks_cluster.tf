resource "databricks_cluster" "herbalife_single_node" {
  cluster_name            = "herbalife-single-node"
  spark_version           = "16.4.x-scala2.12"
  node_type_id            = "Standard_D8s_v3"
  autotermination_minutes = 30
  
  # For a true Single Node cluster, set workers to 0
  num_workers = 0 
  
  # This setting resolves the Isolation error
  data_security_mode = "SINGLE_USER"

  spark_conf = {
    # Required for Single Node clusters
    "spark.databricks.cluster.profile" : "singleNode"
    "spark.master" : "local[*]"
  }

  custom_tags = {
    "ResourceClass" = "SingleNode"
  }
}
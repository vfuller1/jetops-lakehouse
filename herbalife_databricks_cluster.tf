resource "databricks_cluster" "herbalife_single_node" {
  cluster_name            = "herbalife-single-node"
  spark_version           = "16.4.x-scala2.12"
  node_type_id            = "Standard_D8s_v3"
    autotermination_minutes = 30
    num_workers             = 0
    data_security_mode      = "LEGACY_SINGLE_USER_STANDARD"
    driver_node_type_id     = "Standard_D8s_v3"
    runtime_engine          = "PHOTON"
    spark_conf = {
      "spark.master" = "local[*, 4]"
      "spark.databricks.cluster.profile" = "singleNode"
    }
    custom_tags = {
      ResourceClass = "SingleNode"
    }
    enable_elastic_disk = true
    enable_local_disk_encryption = false
}
variable "herbalife_databricks_secret_scope" {
  description = "Databricks secret scope name for Herbalife storage access."
  type        = string
  default     = "herbalife-storage"
}

variable "herbalife_bronze_sas_secret_key" {
  description = "Secret key name that stores the bronze container SAS token."
  type        = string
  default     = "bronze-sas-token"
}

variable "herbalife_bronze_sas_token" {
  description = "SAS token for the Herbalife bronze container. Supply this via TF_VAR_herbalife_bronze_sas_token or a CI secret."
  type        = string
  sensitive   = true
}
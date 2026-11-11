# Auto-populated by 2-project-factory (<project>.auto.tfvars.json)

variable "project_id" {
  description = "GCP project ID created by 2-project-factory."
  type        = string
}

variable "number" {
  description = "GCP project number created by 2-project-factory."
  type        = string
  default     = null
}

variable "aspect_types" {
  description = "Dataplex aspect types created by 2-project-factory."
  type        = any
  default     = {}
}

variable "automation" {
  description = "Project-level automation resources created by 2-project-factory."
  type        = any
  default     = {}
}

variable "bigquery_datasets" {
  description = "BigQuery datasets pre-created by 2-project-factory."
  type        = map(string)
  default     = {}
}

variable "custom_roles" {
  description = "Project custom roles created by 2-project-factory."
  type        = map(string)
  default     = {}
}

variable "kms_keys" {
  description = "KMS keys available to this project."
  type        = map(string)
  default     = {}
}

variable "log_buckets" {
  description = "Logging buckets created by 2-project-factory."
  type        = map(string)
  default     = {}
}

variable "pubsub_topics" {
  description = "Pub/Sub topics pre-created by 2-project-factory."
  type        = map(string)
  default     = {}
}

variable "service_accounts" {
  description = "Service accounts created by 2-project-factory."
  type        = any
  default     = {}
}

variable "storage_buckets" {
  description = "Cloud Storage buckets pre-created by 2-project-factory."
  type        = map(string)
  default     = {}
}

variable "tag_keys" {
  description = "Project tag keys created by 2-project-factory."
  type        = map(string)
  default     = {}
}

variable "tag_values" {
  description = "Project tag values created by 2-project-factory."
  type        = map(string)
  default     = {}
}

variable "tag_vars" {
  description = "Project tag namespaced names created by 2-project-factory."
  type        = map(string)
  default     = {}
}

variable "workload_identity_pools" {
  description = "Workload identity pools created by 2-project-factory."
  type        = map(string)
  default     = {}
}

variable "workload_identity_providers" {
  description = "Workload identity providers created by 2-project-factory."
  type        = any
  default     = {}
}

variable "region" {
  description = "Default GCP region (Frankfurt per ADR 0002)."
  type        = string
  default     = "europe-west3"
}

variable "data_foundation" {
  description = "Cross-component contract exported by components/data-foundation/_infra."
  type = object({
    project_id    = optional(string)
    pubsub_topics = optional(map(string), {})
    datasets      = optional(map(string), {})
    bigtable_id   = optional(string)
  })
  default = {}
}

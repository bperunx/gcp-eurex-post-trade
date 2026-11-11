output "data_foundation" {
  description = "Shared data-foundation resource contract consumed by downstream components."
  value = {
    project_id    = var.project_id
    pubsub_topics = var.pubsub_topics
    datasets      = var.bigquery_datasets
    bigtable_id   = null
  }
}

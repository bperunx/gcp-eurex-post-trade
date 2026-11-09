provider "google" {
  project = var.project_id
  region  = var.region
}

# Shared resources (networking, KMS key rings, VPC Service Controls, IAM)
# are added here as the components are built.

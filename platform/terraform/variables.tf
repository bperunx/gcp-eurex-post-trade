variable "project_id" {
  description = "Google Cloud project that hosts the reference platform."
  type        = string
}

variable "region" {
  description = "Default region. Frankfurt keeps data in the EU."
  type        = string
  default     = "europe-west3"
}

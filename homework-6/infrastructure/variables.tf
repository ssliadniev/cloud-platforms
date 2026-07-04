variable "project_id" {
  description = "The ID of the Google Cloud project"
  type        = string
}

variable "region" {
  description = "The GCP region to deploy resources in"
  type        = string
  default     = "us-central1"
}

variable "bucket_name" {
  description = "Name for the GCS bucket storing PDFs"
  type        = string
  default     = "my-rag-company-data-pdfs-bucket-001"
}

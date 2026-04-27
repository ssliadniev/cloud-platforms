variable "project_id" {
  description = "The ID of your Google Cloud project"
  type        = string
}

variable "region" {
  description = "The GCP region to deploy resources into"
  type        = string
  default     = "us-central1"
}

variable "db_password" {
  description = "Password for the PostgreSQL admin user"
  type        = string
  sensitive   = true
}

variable "project_id" {
  type        = string
  description = "The GCP Project ID"
  default     = "cloud-platforms-493222"
}

variable "region" {
  type        = string
  description = "The primary GCP region for resources"
  default     = "us-central1"
}

variable "location" {
  type        = string
  description = "The location for the Document AI processor"
  default     = "us"
}

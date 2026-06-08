variable "project_id" {
  description = "The GCP Project ID"
  type        = string
}

variable "region" {
  description = "The region for resources"
  type        = string
  default     = "us-central1"
}

variable "prefix" {
  description = "Prefix for naming resources"
  type        = string
  default     = "ocr-poc"
}

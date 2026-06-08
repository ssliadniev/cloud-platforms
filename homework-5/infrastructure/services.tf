variable "gcp_service_list" {
  description = "APIs necessary for the pipeline"
  type        = list(string)
  default = [
    "cloudfunctions.googleapis.com",
    "cloudbuild.googleapis.com",
    "run.googleapis.com",
    "eventarc.googleapis.com",
    "documentai.googleapis.com",
    "storage.googleapis.com",
    "pubsub.googleapis.com"
  ]
}

resource "google_project_service" "gcp_services" {
  for_each                   = toset(var.gcp_service_list)
  project                    = var.project_id
  service                    = each.key
  disable_dependent_services = false
  disable_on_destroy         = false
}

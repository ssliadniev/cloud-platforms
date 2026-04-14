resource "google_artifact_registry_repository" "webapi_repo" {
  location      = var.region
  repository_id = "webapi-repo-tf"
  description   = "Docker repository for ASP.NET Web API (Terraform Managed)"
  format        = "DOCKER"
}

resource "google_cloud_run_v2_service" "webapi_service" {
  name     = "webapi-service-tf"
  location = var.region
  ingress  = "INGRESS_TRAFFIC_ALL"

  template {
    containers {
      image = "us-central1-docker.pkg.dev/cloud-platforms-493222/webapi-repo-tf/webapisample:v1"

      ports {
        container_port = 8080
      }

      env {
        name  = "ASPNETCORE_ENVIRONMENT"
        value = "Development"
      }
    }
  }
}

resource "google_cloud_run_v2_service_iam_member" "public_access" {
  project  = google_cloud_run_v2_service.webapi_service.project
  location = google_cloud_run_v2_service.webapi_service.location
  name     = google_cloud_run_v2_service.webapi_service.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

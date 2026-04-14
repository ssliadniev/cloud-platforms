output "artifact_registry_path" {
  description = "The base path to push your Docker images"
  value       = "${google_artifact_registry_repository.webapi_repo.location}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.webapi_repo.name}"
}

output "cloud_run_url" {
  description = "The live public URL of your Cloud Run service"
  value       = google_cloud_run_v2_service.webapi_service.uri
}

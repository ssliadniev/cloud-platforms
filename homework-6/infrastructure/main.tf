resource "google_project_service" "required_apis" {
  for_each = toset([
    "aiplatform.googleapis.com",
    "storage.googleapis.com",
    "bigquery.googleapis.com",
    "run.googleapis.com",
    "artifactregistry.googleapis.com",
    "cloudbuild.googleapis.com"
  ])
  service            = each.key
  disable_on_destroy = false
}

resource "google_storage_bucket" "pdf_storage" {
  name                        = var.bucket_name
  location                    = var.region
  force_destroy               = true
  uniform_bucket_level_access = true
  depends_on                  = [google_project_service.required_apis]
}

resource "google_bigquery_dataset" "rag_dataset" {
  dataset_id  = "company_data_rag"
  location    = var.region
  depends_on  = [google_project_service.required_apis]
}

resource "google_bigquery_table" "document_embeddings" {
  dataset_id = google_bigquery_dataset.rag_dataset.dataset_id
  table_id   = "pdf_embeddings"

  schema = <<EOF
[
  {"name": "chunk_id", "type": "STRING", "mode": "REQUIRED"},
  {"name": "content", "type": "STRING", "mode": "NULLABLE"},
  {"name": "embedding", "type": "FLOAT64", "mode": "REPEATED"},
  {"name": "metadata_source", "type": "STRING", "mode": "NULLABLE"}
]
EOF
}

resource "google_artifact_registry_repository" "rag_repo" {
  location      = var.region
  repository_id = "rag-chatbot-repo"
  description   = "Docker repository for RAG chatbot"
  format        = "DOCKER"
  depends_on    = [google_project_service.required_apis]
}

resource "google_service_account" "function_sa" {
  account_id   = "${var.prefix}-function-sa"
  display_name = "Cloud Function Service Account for OCR PoC"
  depends_on   = [google_project_service.gcp_services]
}

resource "google_project_iam_member" "docai_api_user" {
  project = var.project_id
  role    = "roles/documentai.apiUser"
  member  = "serviceAccount:${google_service_account.function_sa.email}"
}

resource "google_storage_bucket_iam_member" "input_bucket_reader" {
  bucket = google_storage_bucket.input_bucket.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.function_sa.email}"
}

resource "google_storage_bucket_iam_member" "invoice_bucket_writer" {
  bucket = google_storage_bucket.invoice_bucket.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.function_sa.email}"
}

resource "google_storage_bucket_iam_member" "company_data_bucket_writer" {
  bucket = google_storage_bucket.company_data_bucket.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.function_sa.email}"
}

data "google_storage_project_service_account" "gcs_account" {}

resource "google_project_iam_member" "pubsub_publisher" {
  project = var.project_id
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:${data.google_storage_project_service_account.gcs_account.email_address}"
}

resource "google_project_iam_member" "eventarc_receiver" {
  project = var.project_id
  role    = "roles/eventarc.eventReceiver"
  member  = "serviceAccount:${google_service_account.function_sa.email}"
}

resource "google_project_iam_member" "run_invoker" {
  project = var.project_id
  role    = "roles/run.invoker"
  member  = "serviceAccount:${google_service_account.function_sa.email}"
}
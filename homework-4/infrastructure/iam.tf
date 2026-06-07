resource "google_service_account" "function_sa" {
  account_id   = "invoice-processor-sa-v2"
  display_name = "Invoice Processor Cloud Function SA"
}

resource "google_project_iam_member" "storage_admin" {
  project = var.project_id
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.function_sa.email}"
}

resource "google_project_iam_member" "document_ai_user" {
  project = var.project_id
  role    = "roles/documentai.apiUser"
  member  = "serviceAccount:${google_service_account.function_sa.email}"
}

data "google_storage_project_service_account" "gcs_account" {}

resource "google_project_iam_member" "gcs_pubsub_publishing" {
  project = var.project_id
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:${data.google_storage_project_service_account.gcs_account.email_address}"
}

resource "google_project_iam_member" "event_receiver" {
  project = var.project_id
  role    = "roles/eventarc.eventReceiver"
  member  = "serviceAccount:${google_service_account.function_sa.email}"
}

resource "google_project_iam_member" "run_invoker" {
  project = var.project_id
  role    = "roles/run.invoker"
  member  = "serviceAccount:${google_service_account.function_sa.email}"
}

resource "time_sleep" "wait_60_seconds" {
  depends_on = [
    google_project_iam_member.storage_admin,
    google_project_iam_member.document_ai_user,
    google_project_iam_member.gcs_pubsub_publishing,
    google_project_iam_member.event_receiver,
    google_project_iam_member.run_invoker
  ]

  create_duration = "60s"
}

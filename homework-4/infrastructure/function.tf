data "archive_file" "function_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../src"  # Notice the ../ added here
  output_path = "${path.module}/function-source.zip"
}

resource "google_storage_bucket_object" "function_zip_upload" {
  name   = "function-source-${data.archive_file.function_zip.output_md5}.zip"
  bucket = google_storage_bucket.function_source.name
  source = data.archive_file.function_zip.output_path
}

resource "google_cloudfunctions2_function" "invoice_processor" {
  name        = "invoice-processor-function"
  location    = var.region
  description = "Processes invoices via Document AI upon GCS upload"

  build_config {
    runtime     = "python311"
    entry_point = "process_invoice"
    source {
      storage_source {
        bucket = google_storage_bucket.function_source.name
        object = google_storage_bucket_object.function_zip_upload.name
      }
    }
  }

  service_config {
    max_instance_count    = 1
    available_memory      = "256M"
    timeout_seconds       = 60
    service_account_email = google_service_account.function_sa.email

    environment_variables = {
      PROJECT_ID    = var.project_id
      LOCATION      = var.location
      PROCESSOR_ID  = split("/", google_document_ai_processor.invoice_processor.id)[5]
      OUTPUT_BUCKET = google_storage_bucket.output_bucket.name
    }
  }

  event_trigger {
    trigger_region        = var.region
    event_type            = "google.cloud.storage.object.v1.finalized"
    service_account_email = google_service_account.function_sa.email
    event_filters {
      attribute = "bucket"
      value     = google_storage_bucket.input_bucket.name
    }
  }

  depends_on = [
    google_project_iam_member.storage_admin,
    google_project_iam_member.document_ai_user,
    google_project_iam_member.gcs_pubsub_publishing,
    google_project_service.apis,
    time_sleep.wait_60_seconds,
  ]

}

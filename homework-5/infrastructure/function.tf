data "archive_file" "function_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../src"
  output_path = "${path.module}/function-source.zip"
}

resource "google_storage_bucket_object" "function_archive" {
  name   = "function-source-${data.archive_file.function_zip.output_md5}.zip"
  bucket = google_storage_bucket.function_code.name
  source = data.archive_file.function_zip.output_path
}

resource "google_cloudfunctions2_function" "ocr_function" {
  name        = "${var.prefix}-processor"
  location    = var.region
  description = "Processes PDFs and routes JSON to correct bucket"
  
  build_config {
    runtime     = "python311"
    entry_point = "process_pdf"
    source {
      storage_source {
        bucket = google_storage_bucket.function_code.name
        object = google_storage_bucket_object.function_archive.name
      }
    }
  }

  service_config {
    max_instance_count    = 5
    available_memory      = "512M"
    timeout_seconds       = 120
    service_account_email = google_service_account.function_sa.email
    
    environment_variables = {
      PROCESSOR_NAME      = google_document_ai_processor.ocr_processor.id
      INVOICE_BUCKET      = google_storage_bucket.invoice_bucket.name
      COMPANY_DATA_BUCKET = google_storage_bucket.company_data_bucket.name
    }
  }

  event_trigger {
    trigger_region        = var.region
    event_type            = "google.cloud.storage.object.v1.finalized"
    retry_policy          = "RETRY_POLICY_DO_NOT_RETRY"
    service_account_email = google_service_account.function_sa.email
    
    event_filters {
      attribute = "bucket"
      value     = google_storage_bucket.input_bucket.name
    }
  }
  
  depends_on = [
    google_project_iam_member.pubsub_publisher,
    google_project_iam_member.eventarc_receiver,
    google_project_iam_member.run_invoker,
    google_project_service.gcp_services
  ]
}

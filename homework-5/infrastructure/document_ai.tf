resource "google_document_ai_processor" "ocr_processor" {
  location     = "us"
  display_name = "${var.prefix}-ocr-processor"
  type         = "OCR_PROCESSOR"
  depends_on   = [google_project_service.gcp_services]
}

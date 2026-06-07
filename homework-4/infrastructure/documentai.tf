resource "google_document_ai_processor" "invoice_processor" {
  location     = var.location
  display_name = "invoice-ocr-processor"
  type         = "OCR_PROCESSOR"

  depends_on   = [google_project_service.apis]
}

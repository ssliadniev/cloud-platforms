resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "google_storage_bucket" "input_bucket" {
  name                        = "${var.prefix}-input-${random_id.bucket_suffix.hex}"
  location                    = var.region
  uniform_bucket_level_access = true
  force_destroy               = true
  depends_on                  = [google_project_service.gcp_services]
}

resource "google_storage_bucket" "invoice_bucket" {
  name                        = "${var.prefix}-invoices-${random_id.bucket_suffix.hex}"
  location                    = var.region
  uniform_bucket_level_access = true
  force_destroy               = true
}

resource "google_storage_bucket" "company_data_bucket" {
  name                        = "${var.prefix}-company-data-${random_id.bucket_suffix.hex}"
  location                    = var.region
  uniform_bucket_level_access = true
  force_destroy               = true
}

resource "google_storage_bucket" "function_code" {
  name                        = "${var.prefix}-code-${random_id.bucket_suffix.hex}"
  location                    = var.region
  uniform_bucket_level_access = true
  force_destroy               = true
}

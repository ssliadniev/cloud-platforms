resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "google_storage_bucket" "input_bucket" {
  name                        = "invoice-input-${random_id.bucket_suffix.hex}"
  location                    = var.region
  uniform_bucket_level_access = true
  force_destroy               = true
}

resource "google_storage_bucket" "output_bucket" {
  name                        = "invoice-output-${random_id.bucket_suffix.hex}"
  location                    = var.region
  uniform_bucket_level_access = true
  force_destroy               = true
}

resource "google_storage_bucket" "function_source" {
  name                        = "function-source-${random_id.bucket_suffix.hex}"
  location                    = var.region
  uniform_bucket_level_access = true
  force_destroy               = true
}

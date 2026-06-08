output "input_bucket_name" {
  value = google_storage_bucket.input_bucket.name
}

output "invoice_bucket_name" {
  value = google_storage_bucket.invoice_bucket.name
}

output "company_data_bucket_name" {
  value = google_storage_bucket.company_data_bucket.name
}

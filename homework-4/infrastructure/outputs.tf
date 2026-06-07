output "input_bucket_name" {
  value       = google_storage_bucket.input_bucket.name
  description = "Upload your PDFs here to trigger the function."
}

output "output_bucket_name" {
  value       = google_storage_bucket.output_bucket.name
  description = "Your JSON results will appear here."
}

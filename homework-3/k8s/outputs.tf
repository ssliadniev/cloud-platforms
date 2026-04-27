output "gcp_instance_ip" {
  description = "The public IP address of the Cloud SQL instance"
  value       = google_sql_database_instance.postgres_instance.public_ip_address
}

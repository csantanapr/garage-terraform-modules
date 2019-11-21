output "postgresql_service_account_username" {
  value       = "${data.kubernetes_secret.binding.data.username}"
  description = "Username for the Databases for PostgreSQL service account."
}

output "postgresql_service_account_password" {
  value       = "${data.kubernetes_secret.binding.data.password}"
  description = "Password for the Databases for PostgreSQL Sservice account."
  sensitive   = true
}

output "postgresql_hostname" {
  value       = "${data.kubernetes_secret.binding.data.hostname}"
  description = "Hostname for the Databases for PostgreSQL instance."
}

output "postgresql_port" {
  value       = "${data.kubernetes_secret.binding.data.port}"
  description = "Port for the Databases for PostgreSQL instance."
}

output "postgresql_database_name" {
  value       = "${data.kubernetes_secret.binding.data.database}"
  description = "Database name for the Databases for PostgreSQL instance."
}

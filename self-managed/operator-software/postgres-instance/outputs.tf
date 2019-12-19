output "postgresql_service_account_username" {
  value       = "${local.database_user}"
  description = "Username for the Databases for PostgreSQL service account."
}

output "postgresql_service_account_password" {
  value       = "${data.local_file.password.content}"
  description = "Password for the Databases for PostgreSQL Sservice account."
  sensitive   = true
}

output "postgresql_hostname" {
  value       = "${local.instance_name}"
  description = "Hostname for the Databases for PostgreSQL instance."
}

output "postgresql_port" {
  value       = "5432"
  description = "Port for the Databases for PostgreSQL instance."
}

output "postgresql_database_name" {
  value       = "${local.database_name}"
  description = "Database name for the Databases for PostgreSQL instance."
}

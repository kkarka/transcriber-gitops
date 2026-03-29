# modules/database/outputs.tf

output "db_endpoint" {
  description = "The connection endpoint for the Postgres database"
  value       = aws_db_instance.postgres.endpoint
}
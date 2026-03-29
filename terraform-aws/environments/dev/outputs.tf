output "rds_hostname" {
  description = "RDS instance hostname"
  value       = module.database.db_instance_address # Adjust the module path if needed
}
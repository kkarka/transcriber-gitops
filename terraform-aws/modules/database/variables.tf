variable "environment" {
  description = "The deployment environment"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC where the DB will live"
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block of the VPC to allow internal traffic"
  type        = string
}

variable "subnet_ids" {
  description = "The subnets where the DB will be deployed"
  type        = list(string)
}

variable "db_username" {
  description = "Database administrator username"
  type        = string
}

variable "db_password" {
  description = "Database administrator password"
  type        = string
  sensitive   = true
}
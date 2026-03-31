variable "environment" {
  description = "The deployment environment"
  type        = string
}

variable "subnet_ids" {
  description = "The public subnets where the worker nodes will live"
  type        = list(string)
}

variable "region" {
  description = "The AWS region for RDS IAM authentication ARNs"
  type        = string
  default     = "ap-south-1"
}
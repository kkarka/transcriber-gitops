variable "environment" {
  description = "The deployment environment"
  type        = string
}

variable "subnet_ids" {
  description = "The public subnets where the worker nodes will live"
  type        = list(string)
}
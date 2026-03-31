variable "environment" {
  description = "The deployment environment (e.g., dev, prod)"
  type = string
}

variable "video_bucket_name" {
  description = "The name of the S3 bucket for video storage"
  type = string
}

variable "eks_node_role_name" {
  description = "The name of the IAM role associated with the EKS node group"
  type = string
}
output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = aws_eks_cluster.main.name
}

output "cluster_endpoint" {
  description = "The endpoint URL for the EKS control plane"
  value       = aws_eks_cluster.main.endpoint
}
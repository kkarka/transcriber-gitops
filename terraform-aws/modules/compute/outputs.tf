output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = aws_eks_cluster.main.name
}

output "cluster_endpoint" {
  description = "The endpoint URL for the EKS control plane"
  value       = aws_eks_cluster.main.endpoint
}

output "eks_node_group_role_name" {
  description = "The name of the IAM role for EKS worker nodes"
  value       = aws_iam_role.eks_node_role.name 
}
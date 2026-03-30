# ------------------------------------------------------
# 1. CLUSTER IAM ROLE (The Brain's Permissions)
# ------------------------------------------------------
resource "aws_iam_role" "eks_cluster_role" {
  name = "transcriber-eks-cluster-role-${var.environment}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "eks.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

# ------------------------------------------------------
# 2. THE EKS CLUSTER
# ------------------------------------------------------
resource "aws_eks_cluster" "main" {
  name     = "transcriber-cluster-${var.environment}"
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = "1.30" # Latest stable version

  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_public_access  = true
    endpoint_private_access = true
  }

  depends_on = [aws_iam_role_policy_attachment.eks_cluster_policy]
}

# ------------------------------------------------------
# 3. NODE GROUP IAM ROLE (The Workers' Permissions)
# ------------------------------------------------------
resource "aws_iam_role" "eks_node_role" {
  name = "transcriber-eks-node-role-${var.environment}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "node_worker_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "node_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "node_ecr_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_role.name
}

# ------------------------------------------------------
# 4. THE SPOT INSTANCE NODE GROUP
# ------------------------------------------------------
# resource "aws_eks_node_group" "spot_nodes" {
#   cluster_name    = aws_eks_cluster.main.name
#   node_group_name = "transcriber-spot-nodes-${var.environment}"
#   node_role_arn   = aws_iam_role.eks_node_role.arn
#   subnet_ids      = var.subnet_ids

#   # The magic that makes this affordable!
#   capacity_type  = "ON_DEMAND"
#   instance_types = ["t3.micro"] 

#   scaling_config {
#     desired_size = 8 # 8 nodes = 16 usable pod slots
#     max_size     = 10
#     min_size     = 2
#   }

#   depends_on = [
#     aws_iam_role_policy_attachment.node_worker_policy,
#     aws_iam_role_policy_attachment.node_cni_policy,
#     aws_iam_role_policy_attachment.node_ecr_policy,
#   ]
# }


# ------------------------------------------------------
# 5. THE NEW HIGH-MEMORY NODE GROUP (m7i-flex.large)
# ------------------------------------------------------
resource "aws_eks_node_group" "ai_worker_nodes" {
  cluster_name    = aws_eks_cluster.main.name
  # Give it a new, unique name
  node_group_name = "transcriber-m7i-nodes-${var.environment}" 
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = var.subnet_ids

  capacity_type  = "ON_DEMAND"
  # The new powerhouse instance
  instance_types = ["m7i-flex.large"] 

  scaling_config {
    # You only need 1 or 2 of these. 
    # Just ONE of these has the same RAM as all 8 of your t3.micros combined!
    desired_size = 1 
    max_size     = 2
    min_size     = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.node_worker_policy,
    aws_iam_role_policy_attachment.node_cni_policy,
    aws_iam_role_policy_attachment.node_ecr_policy,
  ]
}
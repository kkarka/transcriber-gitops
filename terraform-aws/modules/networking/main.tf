# 1. The VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "transcriber-vpc-${var.environment}"
  }
}

# 2. Internet Gateway (Allows outside traffic in)
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "transcriber-igw-${var.environment}"
  }
}

# 3. Public Subnets (Iterates over the lists provided to create 2 subnets)
resource "aws_subnet" "public" {
  count                   = length(var.public_subnets)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true

  # EKS strictly requires this tag on public subnets to deploy external load balancers!
  tags = {
    Name                                        = "transcriber-public-${var.azs[count.index]}-${var.environment}"
    "kubernetes.io/role/elb"                    = "1" 
    "kubernetes.io/cluster/transcriber-cluster-${var.environment}" = "shared"
  }
}

# 4. Route Table and Associations
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "transcriber-public-rt-${var.environment}"
  }
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public_rt.id
}
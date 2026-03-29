# 1. Security Group (The Firewall)
# We strictly allow Postgres traffic (Port 5432) ONLY from inside your VPC network.
resource "aws_security_group" "rds_sg" {
  name        = "transcriber-rds-sg-${var.environment}"
  description = "Allow internal Postgres traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr] 
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "transcriber-rds-sg-${var.environment}"
  }
}

# 2. DB Subnet Group (Tells RDS which subnets it is allowed to use)
resource "aws_db_subnet_group" "main" {
  name       = "transcriber-db-subnet-group-${var.environment}"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "transcriber-db-subnet-group-${var.environment}"
  }
}

# 3. The RDS Postgres Instance
resource "aws_db_instance" "postgres" {
  identifier             = "transcriber-db-${var.environment}"
  engine                 = "postgres"
  engine_version         = "15"
  instance_class         = "db.t3.micro" # AWS Free Tier Eligible
  allocated_storage      = 20            # 20 GB is Free Tier Eligible
  
  db_name                = "transcriberdb"
  username               = var.db_username
  password               = var.db_password
  
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  
  publicly_accessible    = false # Highly secure: No internet access allowed
  skip_final_snapshot    = true  # Important for Dev: Allows easy deletion without hanging
}
# Generate a random string to ensure the S3 bucket name is globally unique
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# The S3 Bucket to hold the Terraform state files
resource "aws_s3_bucket" "terraform_state" {
  bucket = "transcriber-tf-state-${random_string.suffix.result}"
  
  lifecycle {
    prevent_destroy = true 
  }
}

# Enable Versioning for state file backups
resource "aws_s3_bucket_versioning" "state_versioning" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Encrypt the state file
resource "aws_s3_bucket_server_side_encryption_configuration" "state_crypto" {
  bucket = aws_s3_bucket.terraform_state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# The DynamoDB Table for the State Lock
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "transcriber-tf-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
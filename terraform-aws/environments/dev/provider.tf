terraform {
  required_version = ">= 1.5.0"

  # THIS IS YOUR REMOTE STATE LOCK
  backend "s3" {
    bucket         = "transcriber-tf-state-jsi4du"  # Your unique bucket
    key            = "dev/terraform.tfstate"        # Isolates this state to the 'dev' folder
    region         = "ap-south-1"                      # Your bucket's region
    dynamodb_table = "transcriber-tf-locks"         # Your DynamoDB lock table
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"

  # Automatically tags every resource created in this environment
  default_tags {
    tags = {
      Environment = "dev"
      Project     = "Transcriber"
      ManagedBy   = "Terraform"
    }
  }
}
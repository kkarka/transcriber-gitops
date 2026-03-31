resource "aws_s3_bucket" "videos" {
  # We append the environment to keep dev and prod separate
  bucket        = "${var.video_bucket_name}-${var.environment}"
  force_destroy = true # Allows terraform to delete the bucket even if it has videos inside
}

# Block all public access (Safety First!)
resource "aws_s3_bucket_public_access_block" "video_access" {
  bucket = aws_s3_bucket.videos.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_cors_configuration" "video_bucket_cors" {
  bucket = aws_s3_bucket.videos.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT", "POST", "GET"]
    allowed_origins = ["https://transcriber.arkadevops.in"] 
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

# 1. Define the IAM Policy
resource "aws_iam_policy" "transcriber_s3_policy" {
  name        = "TranscriberS3AccessPolicy-${var.environment}"
  description = "Allows EKS workers to access the transcription S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:DeleteObject",
          "rds-db:connect"
        ]
        # Uses your specific bucket name from the GitOps configuration
        Resource = [
          "${aws_s3_bucket.videos.arn}",
          "${aws_s3_bucket.videos.arn}/*",
          "arn:aws:rds-db:ap-south-1:*:dbuser:*/transcriberadmin"
        ]
      }
    ]
  })
}

# 2. Attach the policy to your EKS Node Group Role
# Replace 'var.eks_node_role_name' with your actual EKS node role variable
resource "aws_iam_role_policy_attachment" "s3_attachment" {
  policy_arn = aws_iam_policy.transcriber_s3_policy.arn
  role       = var.eks_node_role_name 
}
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
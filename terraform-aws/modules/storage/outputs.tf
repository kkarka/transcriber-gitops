output "actual_bucket_name" {
  description = "The name of the bucket created"
  value       = aws_s3_bucket.videos.id
}
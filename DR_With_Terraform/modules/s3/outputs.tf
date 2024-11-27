output "s3_bucket_id" {
  description = "The ID of created S3 Bucket"
  value = aws_s3_bucket.this.id
}
resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_acl" "example" {
  bucket = aws_s3_bucket.this.id
  acl = "private"
}

resource "aws_s3_object" "this" {
  bucket = aws_s3_bucket.this.bucket
  key = "backup-file"
  source = "local-backup-file-path"
}

resource "aws_s3_object" "replica" {
  bucket = var.replica_bucket
  key = aws_s3_object.this.key
  source = aws_s3_bucket.this.source  
}

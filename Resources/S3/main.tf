provider "aws" {
    region = "us-east-1"
}

resource "aws_s3_bucket" "my_bucket" {
    bucket = "my-sid-bucket-3121" #Must be Globally Unique
    tags = {
      Name = "MyS3Bucket"
    }
}

resource "aws_s3_bucket_public_access_block" "public_access" {  
    bucket = aws_s3_bucket.my_bucket.id
    block_public_acls = true
    block_public_policy = true
    ignore_public_acls = true
    restrict_public_buckets = true
}

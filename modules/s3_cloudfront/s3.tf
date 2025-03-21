# modules/s3_cloudfront/main.tf
resource "aws_s3_bucket" "website" {
  bucket = var.bucket_name

  tags = {
    Name = var.bucket_name
  }
}

# Disable Block Public Access for ACLs and policies
resource "aws_s3_bucket_public_access_block" "website" {
  bucket = aws_s3_bucket.website.id

  block_public_acls       = false # Allow public ACLs
  block_public_policy     = false # Allow public bucket policies
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Add the bucket policy to allow public read access
resource "aws_s3_bucket_policy" "website" {
  bucket = aws_s3_bucket.website.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.website.arn}/*"
      }
    ]
  })
}

# Set the bucket ACL to public-read
resource "aws_s3_bucket_acl" "s3_bucket_acl" {
  bucket = aws_s3_bucket.website.id
  acl    = "public-read"
  depends_on = [aws_s3_bucket_public_access_block.website]
}

# Resource to avoid error "AccessControlListNotSupported: The bucket does not allow ACLs"
resource "aws_s3_bucket_ownership_controls" "s3_bucket_acl_ownership" {
  bucket = aws_s3_bucket.website.id
  rule {
    object_ownership = "ObjectWriter"
  }
}
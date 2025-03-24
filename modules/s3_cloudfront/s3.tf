# Create the S3 bucket
resource "aws_s3_bucket" "website" {
  bucket = var.bucket_name

  tags = {
    Name = var.bucket_name
  }
}

# Disable all Block Public Access settings
resource "aws_s3_bucket_public_access_block" "website" {
  bucket                  = aws_s3_bucket.website.id
  block_public_acls       = false  # Allow ACLs to be set
  block_public_policy     = false  # Allow public bucket policies
  ignore_public_acls      = false
  restrict_public_buckets = false  # Allow public access via policy
}

# Ensure correct ownership settings
resource "aws_s3_bucket_ownership_controls" "website" {
  bucket = aws_s3_bucket.website.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# Apply a public bucket policy
resource "aws_s3_bucket_policy" "website" {
  bucket = aws_s3_bucket.website.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.website.arn}/*"
      }
    ]
  })
}

# Remove ACL configuration (optional, since ACLs are not required)
resource "aws_s3_bucket_acl" "s3_bucket_acl" {
  bucket = aws_s3_bucket.website.id
  acl    = "public-read"
  depends_on = [aws_s3_bucket_public_access_block.website, aws_s3_bucket_ownership_controls.website]
}

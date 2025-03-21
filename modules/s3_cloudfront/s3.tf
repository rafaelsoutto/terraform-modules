module "s3_cloudfront" {
  source = "./modules/s3_cloudfront"
}

# modules/s3_cloudfront/main.tf
resource "aws_s3_bucket" "website" {
  bucket = var.bucket_name

  tags = {
    Name = var.bucket_name
  }
}

resource "aws_s3_bucket_policy" "website" {
  bucket = aws_s3_bucket.website.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "AllowCloudFrontAccess",
        Effect    = "Allow",
        Principal = { "AWS": "*" },
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.website.arn}/*"
      }
    ]
  })
}


resource "aws_s3_bucket_cors" "website" {
  bucket = aws_s3_bucket.website.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD", "PUT"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}
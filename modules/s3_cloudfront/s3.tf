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

resource "aws_cloudfront_distribution" "cdn" {
  origin {
    domain_name = aws_s3_bucket.website.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.website.id
  }

  enabled               = true
  default_root_object   = "index.html"
  aliases              = var.cnames
  price_class = var.price_class


  default_cache_behavior {
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = aws_s3_bucket.website.id
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  custom_error_response {
    error_code            = 404
    response_page_path    = "/index.html"
    response_code         = 200
    error_caching_min_ttl = 300
  }

  viewer_certificate {
    acm_certificate_arn      = var.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  dynamic "web_acl_id" {
    for_each = var.enable_waf ? [1] : []
    content {
      web_acl_id = "your-waf-acl-id"
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = var.geo_restriction_enabled ? "whitelist" : "none"
      locations        = var.geo_restriction_locations
    }

  }

  tags = var.tags

}

# modules/s3_cloudfront/variables.tf
variable "bucket_name" {
  description = "The name of the S3 bucket."
  type        = string
}

variable "enable_waf" {
  description = "Enable WAF for CloudFront distribution."
  type        = bool
  default     = false
}

variable "cnames" {
  description = "List of CNAMEs for CloudFront distribution."
  type        = list(string)
  default     = []
}

variable "acm_certificate_arn" {
  description = "ACM certificate ARN for CloudFront."
  type        = string
  default     = ""
}

variable "price_class" {
  description = "Price class for CloudFront distribution."
  type        = string
  default     = "PriceClass_200"
}

variable "tags" {
  description = "Tags for the CloudFront distribution."
  type        = map(string)
  default     = {}
}

variable "geo_restriction_enabled" {
  description = "Enable geo restriction for CloudFront distribution."
  type        = bool
  default     = false
}

variable "geo_restriction_locations" {
  description = "List of locations for geo restriction."
  type        = list(string)
  default     = []
}

# modules/s3_cloudfront/outputs.tf
output "cloudfront_url" {
  description = "CloudFront distribution URL."
  value       = aws_cloudfront_distribution.cdn.domain_name
}


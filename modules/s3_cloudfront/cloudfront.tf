resource "aws_cloudfront_distribution" "cdn" {
  origin {
    domain_name = aws_s3_bucket.website.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.website.id
  }

  enabled             = true
  default_root_object = "index.html"
  aliases             = var.cnames
  price_class         = var.price_class

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
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 5
  }

  custom_error_response {
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 5
  }


  viewer_certificate {
    cloudfront_default_certificate = var.acm_certificate_arn == "" ? true : false
    acm_certificate_arn            = var.acm_certificate_arn != "" ? var.acm_certificate_arn : null
    ssl_support_method             = var.acm_certificate_arn != "" ? "sni-only" : null
    minimum_protocol_version       = var.acm_certificate_arn != "" ? "TLSv1.2_2021" : null
  }

  # Corrected web_acl_id configuration
  web_acl_id = var.enable_waf ? var.web_acl_id : null

  restrictions {
    geo_restriction {
      restriction_type = var.geo_restriction_enabled ? "whitelist" : "none"
      locations        = var.geo_restriction_locations
    }
  }

  tags = var.tags
}
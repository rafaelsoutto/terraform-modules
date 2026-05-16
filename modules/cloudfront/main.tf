resource "aws_cloudfront_origin_access_control" "this" {
  name                              = replace(var.origin.bucket_domain_name, ".", "-")
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "this" {
  enabled             = true
  default_root_object = "index.html"
  price_class         = var.price_class
  aliases             = var.cnames
  web_acl_id          = var.enable_waf ? var.web_acl_id : null
  tags                = var.tags

  dynamic "logging_config" {
    for_each = var.enable_logging && var.logging_bucket != null ? [1] : []
    content {
      include_cookies = false
      bucket          = var.logging_bucket
      prefix          = var.logging_bucket_prefix
    }
  }

  origin {
    domain_name              = var.origin.bucket_domain_name
    origin_id                = var.origin.bucket_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.this.id
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = var.origin.bucket_domain_name
    viewer_protocol_policy = "redirect-to-https"
    cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6" # CachingOptimized managed policy
    response_headers_policy_id = var.enable_response_headers_policy ? (
      length(var.response_headers_policy_ids) > 0 ? var.response_headers_policy_ids[0] : "SecurityHeadersPolicy" # Default managed policy
    ) : null
  }

  dynamic "custom_error_response" {
    for_each = var.spa_mode ? [403, 404] : []
    content {
      error_code         = custom_error_response.value
      response_code      = 200
      response_page_path = "/index.html"
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = length(var.geo_restriction_locations) > 0 ? "whitelist" : "none"
      locations        = var.geo_restriction_locations
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = var.acm_certificate_arn == null
    acm_certificate_arn            = var.acm_certificate_arn
    ssl_support_method             = var.acm_certificate_arn != null ? "sni-only" : null
    minimum_protocol_version       = var.acm_certificate_arn != null ? "TLSv1.2_2021" : "TLSv1"
  }
}

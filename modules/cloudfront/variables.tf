variable "origin" {
  description = "S3 bucket origin for the CloudFront distribution"
  type = object({
    bucket_arn         = string
    bucket_domain_name = string
  })
}

variable "spa_mode" {
  description = "When true, routes 403 and 404 errors to index.html for single-page app hosting"
  type        = bool
  default     = false
}

variable "cnames" {
  description = "Alternate domain names (CNAMEs) for the CloudFront distribution"
  type        = list(string)
  default     = []
}

variable "acm_certificate_arn" {
  description = "ACM certificate ARN for HTTPS. Must be in us-east-1."
  type        = string
  default     = null
}

variable "price_class" {
  description = "CloudFront price class"
  type        = string
  default     = "PriceClass_200"
}

variable "enable_waf" {
  description = "Whether to attach a WAF Web ACL to the distribution"
  type        = bool
  default     = false
}

variable "web_acl_id" {
  description = "WAF Web ACL ARN to attach (required when enable_waf is true)"
  type        = string
  default     = null
}

variable "geo_restriction_locations" {
  description = "ISO 3166-1-alpha-2 country codes to whitelist. Empty list disables geo-restriction."
  type        = list(string)
  default     = []
}

variable "enable_logging" {
  description = "Enable CloudFront access logging"
  type        = bool
  default     = true
}

variable "logging_bucket" {
  description = "S3 bucket for CloudFront access logs. Required if enable_logging is true."
  type        = string
  default     = null
}

variable "logging_bucket_prefix" {
  description = "Prefix for CloudFront access logs in S3"
  type        = string
  default     = "cloudfront-logs"
}

variable "enable_response_headers_policy" {
  description = "Enable CloudFront response headers policy for security headers"
  type        = bool
  default     = true
}

variable "response_headers_policy_ids" {
  description = "List of managed response headers policy IDs to attach. If empty and enable_response_headers_policy is true, default security headers policy is used."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to the CloudFront distribution"
  type        = map(string)
  default     = {}
}

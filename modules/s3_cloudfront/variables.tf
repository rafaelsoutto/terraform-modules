
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


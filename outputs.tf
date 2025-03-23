output "bucket_id" {
  description = "The name of the bucket"
  value       = aws_s3_bucket.this.id
}

output "bucket_arn" {
  description = "The ARN of the bucket"
  value       = aws_s3_bucket.this.arn
}

output "bucket_domain_name" {
  description = "The domain name of the bucket"
  value       = aws_s3_bucket.this.bucket_domain_name
}

output "bucket_regional_domain_name" {
  description = "The regional domain name of the bucket"
  value       = aws_s3_bucket.this.bucket_regional_domain_name
}

output "lifecycle_configuration_rules" {
  description = "Map of lifecycle rules applied to the bucket"
  value       = try(aws_s3_bucket_lifecycle_configuration.this[0].rule, null)
}

output "access_logging_enabled" {
  description = "Whether access logging is enabled for the bucket"
  value       = var.enable_access_logging
}

output "replication_enabled" {
  description = "Whether cross-region replication is enabled for the bucket"
  value       = var.enable_replication
}

output "notifications_configured" {
  description = "Whether event notifications are configured for the bucket"
  value       = length(var.event_notifications) > 0
}

output "versioning_enabled" {
  description = "Whether versioning is enabled for the bucket"
  value       = var.versioning
}

output "encryption_type" {
  description = "Type of encryption configured for the bucket"
  value       = var.sse_algorithm
}

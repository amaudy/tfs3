variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "force_destroy" {
  description = "Whether to force destroy the bucket even if it contains objects"
  type        = bool
  default     = false
}

variable "versioning" {
  description = "Enable versioning for the S3 bucket"
  type        = bool
  default     = true
}

variable "sse_algorithm" {
  description = "Server-side encryption algorithm to use. Valid values are AES256 and aws:kms"
  type        = string
  default     = "aws:kms"
}

variable "kms_key_arn" {
  description = "ARN of the KMS key to use for S3 bucket encryption (if sse_algorithm is aws:kms)"
  type        = string
  default     = null
}

variable "block_public_acls" {
  description = "Whether Amazon S3 should block public ACLs for this bucket"
  type        = bool
  default     = true
}

variable "block_public_policy" {
  description = "Whether Amazon S3 should block public bucket policies for this bucket"
  type        = bool
  default     = true
}

variable "ignore_public_acls" {
  description = "Whether Amazon S3 should ignore public ACLs for this bucket"
  type        = bool
  default     = true
}

variable "restrict_public_buckets" {
  description = "Whether Amazon S3 should restrict public bucket policies for this bucket"
  type        = bool
  default     = true
}

variable "lifecycle_rules" {
  description = "List of lifecycle rules to configure (in addition to the default abort incomplete multipart uploads rule)"
  type = list(object({
    id                       = string
    enabled                  = bool
    prefix                   = optional(string)
    expiration_days          = optional(number)
    noncurrent_version_days  = optional(number)
    abort_incomplete_days    = optional(number)
    transition_days          = optional(number)
    transition_storage_class = optional(string)
  }))
  default = []
}

variable "enable_access_logging" {
  description = "Enable access logging for the S3 bucket"
  type        = bool
  default     = false
}

variable "access_log_bucket_name" {
  description = "Name of the S3 bucket to store access logs (required if enable_access_logging is true)"
  type        = string
  default     = null
}

variable "access_log_prefix" {
  description = "Prefix for access log objects"
  type        = string
  default     = "logs/"
}

variable "enable_replication" {
  description = "Enable cross-region replication for the S3 bucket"
  type        = bool
  default     = false
}

variable "replication_destination_bucket_arn" {
  description = "ARN of the destination bucket for replication (required if enable_replication is true)"
  type        = string
  default     = null
}

variable "replication_configuration" {
  description = "Map containing cross-region replication configuration"
  type = object({
    role                     = optional(string)
    destination_bucket       = optional(string)
    storage_class            = optional(string)
    replica_kms_key_id       = optional(string)
    replication_time_minutes = optional(number)
    prefix                   = optional(string)
  })
  default = null
}

variable "event_notifications" {
  description = "Map of event notification configurations"
  type = map(object({
    type        = string       # lambda, sqs, or sns
    events      = list(string) # s3:ObjectCreated:*, s3:ObjectRemoved:*, etc.
    filter_prefix = optional(string)
    filter_suffix = optional(string)
    arn           = string    # ARN of the Lambda/SQS/SNS destination
  }))
  default = {}
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

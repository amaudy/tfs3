resource "aws_s3_bucket" "this" {
  bucket        = var.bucket_name
  force_destroy = var.force_destroy

  tags = var.tags
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = var.versioning ? "Enabled" : "Disabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.sse_algorithm
      kms_master_key_id = var.sse_algorithm == "aws:kms" ? var.kms_key_arn : null
    }
    bucket_key_enabled = var.sse_algorithm == "aws:kms" ? true : null
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}

# Add S3 bucket lifecycle configuration, always including abort_incomplete_multipart_upload and version management
resource "aws_s3_bucket_lifecycle_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  # Always apply a default rule for aborting incomplete multipart uploads
  rule {
    id     = "abort-incomplete-multipart-uploads"
    status = "Enabled"

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }

  # Add versioning lifecycle rule if versioning is enabled
  dynamic "rule" {
    for_each = var.versioning ? [1] : []
    content {
      id     = "versioning-lifecycle-rule"
      status = "Enabled"

      noncurrent_version_expiration {
        noncurrent_days = var.noncurrent_version_expiration
      }

      dynamic "noncurrent_version_transition" {
        for_each = var.noncurrent_version_transitions
        content {
          noncurrent_days = noncurrent_version_transition.value.days
          storage_class   = noncurrent_version_transition.value.storage_class
        }
      }
    }
  }

  # Apply user-defined lifecycle rules if specified
  dynamic "rule" {
    for_each = var.lifecycle_rules
    content {
      id     = rule.value.id
      status = rule.value.enabled ? "Enabled" : "Disabled"

      dynamic "filter" {
        for_each = rule.value.prefix != null ? [rule.value.prefix] : []
        content {
          prefix = filter.value
        }
      }

      dynamic "expiration" {
        for_each = rule.value.expiration_days != null ? [rule.value.expiration_days] : []
        content {
          days = expiration.value
        }
      }

      dynamic "noncurrent_version_expiration" {
        for_each = rule.value.noncurrent_version_days != null ? [rule.value.noncurrent_version_days] : []
        content {
          noncurrent_days = noncurrent_version_expiration.value
        }
      }

      dynamic "transition" {
        for_each = rule.value.transition_days != null && rule.value.transition_storage_class != null ? [true] : []
        content {
          days          = rule.value.transition_days
          storage_class = rule.value.transition_storage_class
        }
      }

      dynamic "abort_incomplete_multipart_upload" {
        for_each = rule.value.abort_incomplete_days != null ? [rule.value.abort_incomplete_days] : []
        content {
          days_after_initiation = abort_incomplete_multipart_upload.value
        }
      }
    }
  }

  # Lifecycle configurations may require versioning
  depends_on = [aws_s3_bucket_versioning.this]
}

# Add S3 bucket access logging if enabled
resource "aws_s3_bucket_logging" "this" {
  count         = var.enable_access_logging && var.access_log_bucket_name != null ? 1 : 0
  bucket        = aws_s3_bucket.this.id
  target_bucket = var.access_log_bucket_name
  target_prefix = var.access_log_prefix
}

# Add replication configuration if enabled
resource "aws_s3_bucket_replication_configuration" "this" {
  count  = var.enable_replication && var.replication_configuration != null ? 1 : 0
  bucket = aws_s3_bucket.this.id
  role   = var.replication_configuration.role

  rule {
    id     = "ReplicationRule"
    status = "Enabled"

    dynamic "filter" {
      for_each = var.replication_configuration.prefix != null ? [var.replication_configuration.prefix] : [null]
      content {
        prefix = filter.value
      }
    }

    destination {
      bucket = var.replication_destination_bucket_arn
      storage_class = var.replication_configuration.storage_class

      dynamic "encryption_configuration" {
        for_each = var.replication_configuration.replica_kms_key_id != null ? [var.replication_configuration.replica_kms_key_id] : []
        content {
          replica_kms_key_id = encryption_configuration.value
        }
      }
    }

    dynamic "source_selection_criteria" {
      for_each = var.sse_algorithm == "aws:kms" ? [true] : []
      content {
        sse_kms_encrypted_objects {
          status = "Enabled"
        }
      }
    }
  }

  # Must have versioning enabled first
  depends_on = [aws_s3_bucket_versioning.this]
}

# Event notification configuration
resource "aws_s3_bucket_notification" "this" {
  count  = length(var.event_notifications) > 0 ? 1 : 0
  bucket = aws_s3_bucket.this.id

  dynamic "lambda_function" {
    for_each = {
      for name, config in var.event_notifications : name => config
      if config.type == "lambda"
    }
    content {
      lambda_function_arn = lambda_function.value.arn
      events              = lambda_function.value.events
      filter_prefix       = lookup(lambda_function.value, "filter_prefix", null)
      filter_suffix       = lookup(lambda_function.value, "filter_suffix", null)
    }
  }

  dynamic "queue" {
    for_each = {
      for name, config in var.event_notifications : name => config
      if config.type == "sqs"
    }
    content {
      queue_arn     = queue.value.arn
      events        = queue.value.events
      filter_prefix = lookup(queue.value, "filter_prefix", null)
      filter_suffix = lookup(queue.value, "filter_suffix", null)
    }
  }

  dynamic "topic" {
    for_each = {
      for name, config in var.event_notifications : name => config
      if config.type == "sns"
    }
    content {
      topic_arn      = topic.value.arn
      events         = topic.value.events
      filter_prefix  = lookup(topic.value, "filter_prefix", null)
      filter_suffix  = lookup(topic.value, "filter_suffix", null)
    }
  }
}

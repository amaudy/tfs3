# AWS S3 Bucket Terraform Module

[![GitHub Repository](https://img.shields.io/badge/GitHub-amaudy/tfs3-blue?style=flat&logo=github)](https://github.com/amaudy/tfs3)
[![Terraform Module Tests](https://github.com/amaudy/tfs3/actions/workflows/terraform-tests.yml/badge.svg)](https://github.com/amaudy/tfs3/actions/workflows/terraform-tests.yml)

This Terraform module creates an AWS S3 bucket with security best practices applied by default and configurable options for:

- Versioning (enabled by default)
- Encryption with KMS (enabled by default)
- Public access blocking (enabled by default)
- Lifecycle rules
- Access logging
- Cross-region replication
- Event notifications

## Usage

```hcl
module "s3_bucket" {
  source = "git::https://github.com/amaudy/tfs3.git"

  bucket_name = "my-unique-bucket-name"
  versioning  = true
  
  tags = {
    Environment = "Production"
    Project     = "MyProject"
  }
}
```

## Requirements

| Name | Version |
|------|--------|
| terraform | >= 1.0.0 |
| aws | >= 4.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| bucket_name | Name of the S3 bucket | `string` | n/a | yes |
| force_destroy | Whether to force destroy the bucket even if it contains objects | `bool` | `false` | no |
| versioning | Enable versioning for the S3 bucket | `bool` | `true` | no |
| noncurrent_version_expiration | Number of days to keep noncurrent versions before deletion | `number` | `90` | no |
| noncurrent_version_transitions | List of transition configurations for noncurrent versions | `list(object)` | See below | no |
| sse_algorithm | Server-side encryption algorithm to use | `string` | `"aws:kms"` | no |
| kms_key_arn | ARN of the KMS key to use for S3 bucket encryption | `string` | `null` | no |
| block_public_acls | Whether Amazon S3 should block public ACLs for this bucket | `bool` | `true` | no |
| block_public_policy | Whether Amazon S3 should block public bucket policies for this bucket | `bool` | `true` | no |
| ignore_public_acls | Whether Amazon S3 should ignore public ACLs for this bucket | `bool` | `true` | no |
| restrict_public_buckets | Whether Amazon S3 should restrict public bucket policies for this bucket | `bool` | `true` | no |
| lifecycle_rules | List of lifecycle rules to configure | `list(object)` | `[]` | no |
| enable_access_logging | Enable access logging for the S3 bucket | `bool` | `false` | no |
| access_log_bucket_name | Name of the S3 bucket to store access logs | `string` | `null` | no |
| access_log_prefix | Prefix for access log objects | `string` | `"logs/"` | no |
| enable_replication | Enable cross-region replication for the S3 bucket | `bool` | `false` | no |
| replication_destination_bucket_arn | ARN of the destination bucket for replication | `string` | `null` | no |
| replication_configuration | Map containing cross-region replication configuration | `object` | `null` | no |
| event_notifications | Map of event notification configurations | `map(object)` | `{}` | no |
| tags | A map of tags to add to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| bucket_id | The name of the bucket |
| bucket_arn | The ARN of the bucket |
| bucket_domain_name | The domain name of the bucket |
| bucket_regional_domain_name | The regional domain name of the bucket |
| lifecycle_configuration_rules | Map of lifecycle rules applied to the bucket |
| access_logging_enabled | Whether access logging is enabled for the bucket |
| replication_enabled | Whether cross-region replication is enabled for the bucket |
| notifications_configured | Whether event notifications are configured for the bucket |
| versioning_enabled | Whether versioning is enabled for the bucket |
| encryption_type | Type of encryption configured for the bucket |

### Default Version Management

By default, the module includes the following version management settings when versioning is enabled:

```hcl
noncurrent_version_transitions = [
  {
    days          = 30
    storage_class = "STANDARD_IA"
  }
]
noncurrent_version_expiration = 90  # Expires noncurrent versions after 90 days
```

This moves noncurrent versions to the STANDARD_IA storage class after 30 days and deletes them after 90 days.

## Examples

### Basic S3 Bucket (with default security settings)

```hcl
module "s3_bucket" {
  source = "git::https://github.com/amaudy/tfs3.git"

  bucket_name = "my-unique-bucket-name"
}
```

### S3 Bucket with Custom KMS Key

```hcl
module "s3_bucket" {
  source = "git::https://github.com/amaudy/tfs3.git"

  bucket_name   = "my-unique-bucket-name"
  kms_key_arn   = "arn:aws:kms:us-east-1:1234567890:key/abcd1234-1234-1234-1234-1234abcd1234"
  
  tags = {
    Environment = "Production"
  }
}
```

### S3 Bucket with Lifecycle Rules

```hcl
module "s3_bucket" {
  source = "git::https://github.com/amaudy/tfs3.git"

  bucket_name = "my-unique-bucket-name"
  
  lifecycle_rules = [
    {
      id      = "archive-rule"
      enabled = true
      
      transition_days          = 90
      transition_storage_class = "STANDARD_IA"
      
      expiration_days         = 365
      noncurrent_version_days = 30
    }
  ]
}
```

### S3 Bucket with Access Logging and Event Notifications

```hcl
module "s3_bucket" {
  source = "git::https://github.com/amaudy/tfs3.git"

  bucket_name = "my-unique-bucket-name"
  
  # Access logging
  enable_access_logging  = true
  access_log_bucket_name = "my-log-bucket"
  access_log_prefix      = "s3-access-logs/"
  
  # Event notifications (requires existing Lambda/SQS/SNS)
  event_notifications = {
    lambda-notification = {
      type   = "lambda"
      events = ["s3:ObjectCreated:*"]
      arn    = "arn:aws:lambda:us-east-1:1234567890:function:my-lambda-function"
    }
  }
}
```

### S3 Bucket with Cross-Region Replication

```hcl
module "s3_bucket" {
  source = "git::https://github.com/amaudy/tfs3.git"

  bucket_name = "my-unique-bucket-name"
  
  enable_replication               = true
  replication_destination_bucket_arn = "arn:aws:s3:::my-destination-bucket"
  
  replication_configuration = {
    role          = "arn:aws:iam::1234567890:role/my-replication-role"
    storage_class = "STANDARD_IA"
  }
}
```

### S3 Bucket with Custom Version Lifecycle

```hcl
module "s3_bucket" {
  source = "git::https://github.com/amaudy/tfs3.git"

  bucket_name = "my-unique-bucket-name"
  versioning  = true
  
  # Keep only the last 10 versions by deleting older versions after 30 days
  noncurrent_version_expiration = 30
  
  # Move older versions to Glacier after 7 days to save costs
  noncurrent_version_transitions = [
    {
      days          = 7
      storage_class = "GLACIER"
    }
  ]
}
```

## Testing

This module includes automated tests using Terratest. To run the tests:

1. Navigate to the test directory: `cd test`
2. Install dependencies: `go mod tidy`
3. Run the tests: `go test -v`

The tests will create real AWS resources, so make sure you have appropriate AWS credentials and permissions.

## Continuous Integration

This module uses GitHub Actions for continuous integration tests:

1. **Terraform Validate**: Validates the Terraform configuration and checks the formatting
2. **Checkov Security Scan**: Runs security checks against the Terraform code
3. **Terratest Unit Tests**: Executes the Terratest unit tests

For the unit tests to run in your own fork, you'll need to set the following secrets in your GitHub repository:
- `AWS_ACCESS_KEY_ID`: Your AWS access key with permissions to create S3 buckets
- `AWS_SECRET_ACCESS_KEY`: Your AWS secret access key

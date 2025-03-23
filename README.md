# AWS S3 Bucket Terraform Module

This Terraform module creates an AWS S3 bucket with configurable options for versioning, encryption, and public access blocking.

## Usage

```hcl
module "s3_bucket" {
  source = "git::https://github.com/yourusername/tfs3.git"

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
| versioning | Enable versioning for the S3 bucket | `bool` | `false` | no |
| sse_algorithm | Server-side encryption algorithm to use | `string` | `"AES256"` | no |
| block_public_acls | Whether Amazon S3 should block public ACLs for this bucket | `bool` | `true` | no |
| block_public_policy | Whether Amazon S3 should block public bucket policies for this bucket | `bool` | `true` | no |
| ignore_public_acls | Whether Amazon S3 should ignore public ACLs for this bucket | `bool` | `true` | no |
| restrict_public_buckets | Whether Amazon S3 should restrict public bucket policies for this bucket | `bool` | `true` | no |
| tags | A map of tags to add to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| bucket_id | The name of the bucket |
| bucket_arn | The ARN of the bucket |
| bucket_domain_name | The domain name of the bucket |
| bucket_regional_domain_name | The regional domain name of the bucket |

## Examples

### Basic S3 Bucket

```hcl
module "s3_bucket" {
  source = "git::https://github.com/yourusername/tfs3.git"

  bucket_name = "my-unique-bucket-name"
}
```

### S3 Bucket with Versioning and KMS Encryption

```hcl
module "s3_bucket" {
  source = "git::https://github.com/yourusername/tfs3.git"

  bucket_name   = "my-unique-bucket-name"
  versioning    = true
  sse_algorithm = "aws:kms"
  
  tags = {
    Environment = "Production"
  }
}
```

## Testing

This module includes automated tests using Terratest. To run the tests:

1. Navigate to the test directory: `cd test`
2. Install dependencies: `go mod tidy`
3. Run the tests: `go test -v`

The tests will create real AWS resources, so make sure you have appropriate AWS credentials and permissions.

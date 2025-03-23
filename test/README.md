# Testing Terraform S3 Module

This directory contains tests for the S3 bucket Terraform module using Terratest.

## Prerequisites

- [Go](https://golang.org/) (1.18 or later)
- [Terraform](https://www.terraform.io/) (1.0.0 or later)
- AWS credentials configured
- AWS permissions to create and delete S3 buckets

## Running the tests

From this directory, run:

```bash
go mod tidy    # Install dependencies
go test -v     # Run the tests with verbose output
```

The test will:
1. Create a random S3 bucket name to avoid conflicts
2. Deploy the module using the example configuration
3. Verify the S3 bucket exists
4. Clean up all resources when done

## Customizing tests

To add more test cases or check additional properties of the S3 bucket, modify the `s3_bucket_test.go` file.

You can use the AWS SDK functionality provided by Terratest to verify specific bucket settings.
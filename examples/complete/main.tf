provider "aws" {
  region = "us-west-2"
}

module "s3_bucket" {
  source = "../../"

  bucket_name = "my-example-bucket-name-${random_string.random.result}"
  versioning  = true
  
  tags = {
    Environment = "Test"
    Project     = "Example"
  }
}

resource "random_string" "random" {
  length  = 8
  special = false
  upper   = false
}

output "bucket_name" {
  value = module.s3_bucket.bucket_id
}

output "bucket_arn" {
  value = module.s3_bucket.bucket_arn
}

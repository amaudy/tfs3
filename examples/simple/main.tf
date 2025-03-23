provider "aws" {
  region = "us-east-1"
}

module "s3_bucket" {
  source = "../../"

  bucket_name = "my-simple-bucket-example"
}

output "bucket_name" {
  value = module.s3_bucket.bucket_id
}
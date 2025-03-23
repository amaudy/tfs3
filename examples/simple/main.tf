provider "aws" {
  region = "us-east-1"
}

variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
  default     = "my-simple-bucket-example"
}

module "s3_bucket" {
  source = "../../"

  bucket_name = var.bucket_name
}

output "bucket_name" {
  value = module.s3_bucket.bucket_id
}
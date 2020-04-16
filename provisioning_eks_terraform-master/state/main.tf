provider "aws" {
    # This profile maps to the profile name defined in your ~/.aws/credentials
    profile    = "terraform"

    # The default AWS region
    region     = "eu-west-2"

    # Fix a version
    version = "~> 2.56"
}

resource "aws_s3_bucket" "terraform_state_bucket" {
    bucket        = "terraform-state-${var.bucket_name_suffix}"
    force_destroy = true
    versioning {
        enabled    = true
    }
}

resource "aws_dynamodb_table" "terraform_state_lock_dev" {
  name           = "terraform-lock-dev"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
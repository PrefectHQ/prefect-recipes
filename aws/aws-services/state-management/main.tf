module "bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "2.13.0"

  bucket        = var.bucket_name
  force_destroy = false

  versioning = {
    enabled = true
  }

  tags = {
    "managed-by" = "terraform"
  }
}

resource "aws_s3_bucket_public_access_block" "bucket_block" { #tfsec:ignore:aws-s3-enable-bucket-encryption
  bucket = module.bucket.s3_bucket_id

  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}

resource "aws_dynamodb_table" "terraform_state_lock" { #tfsec:ignore:aws-dynamodb-enable-recovery tfsec:ignore:aws-dynamodb-table-customer-key tfsec:ignore:aws-dynamodb-enable-at-rest-encryption
  name          = "terraform-state-lock"
  readcapacity  = 5
  writecapacity = 5
  hash_key      = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    "managed-by" = "terraform"
  }
}
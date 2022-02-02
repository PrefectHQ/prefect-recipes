module "bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "2.13.0"

  bucket        = var.bucket_name
  force_destroy = false

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  versioning = {
    enabled = true
  }

  tags = {
    "managed-by" = "terraform"
  }
}

resource "aws_dynamodb_table" "terraform_state_lock" {
  name           = "terraform-state-lock"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    "managed-by" = "terraform"
  }
}
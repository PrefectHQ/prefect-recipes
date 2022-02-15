resource "aws_s3_bucket" "network_config" { #tfsec:ignore:aws-s3-enable-bucket-logging tfsec:ignore:aws-s3-enable-bucket-encryption
  bucket_prefix = "test-jamie-ecs-network-configuration"
}

resource "aws_s3_bucket_versioning" "bucket_versioning" {
  bucket = aws_s3_bucket.network_config.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "bucket_block" {
  bucket = aws_s3_bucket.network_config.id

  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}

resource "aws_s3_object" "network_config" {
  bucket = aws_s3_bucket.network_config.id
  key    = "network-config.yaml"
  source = "${path.module}/network-config.yaml"
  etag   = filemd5("${path.module}/network-config.yaml")
}
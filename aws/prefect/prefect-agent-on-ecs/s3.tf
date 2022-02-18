resource "aws_s3_bucket" "network_config" { #tfsec:ignore:aws-s3-enable-bucket-logging tfsec:ignore:aws-s3-enable-bucket-encryption
  bucket_prefix = "test-jamie-ecs-network-configuration-"
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
  depends_on = [
    aws_s3_bucket.network_config
  ]
  bucket = aws_s3_bucket.network_config.id
  key    = "network-config.yaml"
  content = templatefile("${path.module}/network-config.yaml.tftpl",
    {
      subnet_ids         = var.subnet_ids,
      security_group_ids = [aws_security_group.sg.id],
      assign_public_ip   = "DISABLED",
    }
  )
  etag = filemd5("${path.module}/network-config.yaml.tftpl")
}
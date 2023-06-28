// S3 Bucket
data "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name
}

// Required in order to generate events for EventBridge
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket      = data.aws_s3_bucket.bucket.id
  eventbridge = true
}

resource "aws_s3_bucket" "bucket" {
  bucket = "tps-airbyte-configuration-${data.aws_region.current.id}"

  versioning {
    enabled = true
  }
}
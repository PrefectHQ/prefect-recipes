resource "aws_s3_bucket" "prefect_ecs_config" { #tfsec:ignore:aws-s3-enable-bucket-logging tfsec:ignore:aws-s3-enable-bucket-encryption
  bucket_prefix = "prefect-ecs-config-"
}

resource "aws_s3_bucket_versioning" "bucket_versioning" {
  bucket = aws_s3_bucket.prefect_ecs_config.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "bucket_block" {
  bucket = aws_s3_bucket.prefect_ecs_config.id

  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}


resource "aws_s3_object" "task_definition" {
  depends_on = [
    aws_s3_bucket.prefect_ecs_config
  ]
  bucket = aws_s3_bucket.prefect_ecs_config.id
  key    = "task-definition.yaml"
  content = templatefile("${path.module}/task-definition.yaml.tftpl",
    {
      region              = var.region
      log_group_name      = var.flow_log_group_name
      log_stream_prefix   = var.flow_log_stream_prefix
      default_task_cpu    = var.default_task_cpu
      default_task_memory = var.default_task_memory
    }
  )
  etag = filemd5("${path.module}/task-definition.yaml.tftpl")
}

resource "aws_s3_object" "network_config" {
  depends_on = [
    aws_s3_bucket.prefect_ecs_config
  ]
  bucket  = aws_s3_bucket.prefect_ecs_config.id
  key     = "network-config.yaml"
  content = yamlencode({ "networkConfiguration" : { "awsvpcConfiguration" : { "subnets" : [for subnet in var.subnet_ids : subnet], "securityGroups" : [aws_security_group.sg.id], "assignPublicIp" : "ENABLED" } } })

}

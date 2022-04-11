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
    {}
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
  # networkConfiguration:
  #   awsvpcConfiguration:
  #     subnets: 
  # %{ for subnet in subnet_ids ~}
  #     - ${subnet}
  # %{ endfor ~}
  #     securityGroups:
  # %{ for sg in security_group_ids ~}
  #     - ${sg}
  # %{ endfor ~}
  #     assignPublicIp: ${assign_public_ip}


  #   templatefile("${path.module}/network-config.yaml.tftpl",
  #     {
  #       subnet_ids         = var.subnet_ids,
  #       security_group_ids = [aws_security_group.sg.id],
  #       assign_public_ip   = "DISABLED",
  #     }
  #   )
  #   etag = filemd5("${path.module}/network-config.yaml.tftpl")
}

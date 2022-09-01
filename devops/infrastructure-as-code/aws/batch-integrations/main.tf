resource "aws_dynamodb_table" "dynamo_db_table" {
  attribute {
    name = "batchState"
    type = "S"
  }
  attribute {
    name = "messageId"
    type = "S"
  }
  attribute {
    name = "timeOfState"
    type = "S"
  }

  ttl {
    attribute_name = "ttl"
    enabled        = true
  }

  name           = var.dbTableName
  hash_key       = var.dbHashKey
  read_capacity  = var.dbReadCapacity
  write_capacity = var.dbWriteCapacity
  global_secondary_index {
    name            = "batchState-timeOfState-index"
    hash_key        = "batchState"
    range_key       = "timeOfState"
    projection_type = "KEYS_ONLY"
    read_capacity   = 1
    write_capacity  = 1
  }
}

data "aws_batch_compute_environment" "batch_compute_environment" {
  compute_environment_name = "Boyd_fargate"
}


module "sqs_to_batch" {
  source = "./sqs_to_batch"

  dynamo_db_table_arn = aws_dynamodb_table.dynamo_db_table.arn
}




# resource "aws_batch_compute_environment" "BatchComputeEnvironment" {
#     compute_environment_name = "Boyd_fargate"
#     type = "MANAGED"
#     state = "ENABLED"
#     service_role = "arn:aws:iam::330830921905:role/aws-service-role/batch.amazonaws.com/AWSServiceRoleForBatch"
#     compute_resources {
#         type = "FARGATE"
#         max_vcpus = 16
#         subnets = [
#             "subnet-0a15883f99127a41b"
#         ]
#         security_group_ids = [
#             "sg-0aff45bb0baf81de9"
#         ]
#         tags {}
#     }
# }

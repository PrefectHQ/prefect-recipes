#Deploys the DynamoDB in the main provider only
#Primary table, and global secondary index are deployed
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

#Retrieve_batch_state.tf runs here as well - deploys api-gateway + lambda to the main provider.
#Lambdas are deployed via deployment.zip
# If lambdas need to be modified, they need to be unzipped first, modified, then repackaged via chalice package --pkg-format terraform .
# The output package is deployment.zip; both app.py and the output deployment.zip should be moved to replace the existing one in IaC.


# I don't believe this is required any longer - batch submissions are handled by the Lambda, and defined prior to entry
data "aws_batch_compute_environment" "batch_compute_environment" {
  # Name of the compute environment name - requires permissions from the user/service account running Terraform to view.
  compute_environment_name = "Boyd_fargate"
}

# Calls the module to deploy the remaining pieces; by default in the same master provider.
# Can be duplicated with other providers to deploy into separate accounts.
# Dynamo_db_table_arn is passed in, as batch_state_updates in other accounts need to know the ARN 
module "sqs_to_batch" {
  source = "./sqs_to_batch"

  dynamo_db_table_arn = aws_dynamodb_table.dynamo_db_table.arn
}

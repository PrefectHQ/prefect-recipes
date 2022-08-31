variable "region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region in which to create resources"
}

variable "dbTableName" {
  type        = string
  description = "Master DynamoDB table for Batch State Tracking. Do not change."
  default     = "batch_state_table"
  # This is a master table for batch state tracking.
  # This value exists in the pre-packaged batch_table_update lambda and the retrieve_batch_state.
  # It _can_ be updated here, but then must be updated in both lambdas which are managed by terraform in .zip format.
}

variable "dbHashKey" {
  type        = string
  description = "Primary Hash Key for dbTableName"
  default     = "messageId"
}

variable "dbReadCapacity" {
  type        = number
  description = "Read capacity for DynamoDB"
  default     = 1
}

variable "dbWriteCapacity" {
  type        = number
  description = "Write capacity for DynamoDB"
  default     = 1
}
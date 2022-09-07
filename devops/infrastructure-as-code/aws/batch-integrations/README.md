# AWS Queue to Batch Implementation

## Purpose 
The AWS Batch submit job has an API limit of 50 transactions per second.
Submitted jobs / tasks / flows that exceed this limit are dropped and failed without retry.
This queue-to-batch implentation detailed in depth below intends to remediate this issue through AWS native services.
The end result is increased throughput and utilization. 
A 2nd order effect of this increased throughput will have increased operating costs, as more batch jobs run concurrently than previously.

## Components
There are a number of components implemented for this solution. 
Some of these components are per account (per batch compute environment), and some are singular, across all accounts.
Inputs and outputs for each component are detailed further down.

| Single Implementation | Name of Object | 
| ----------- | ---------- |
| DynamoDB Table | `batch_state_table`
| Retreieve State Lambda |  `retrieve_batch_state`

| Per AWS Account | Name of Item | 
| ----------- | ---------- | 
| SQS Queue | `sqs_to_batch` |
| Queue to Batch Lambda | `queue_to_batch` | 
| Update Batch Table Lambda | `update_batch_table` |
| Eventbridge Rule Trigger | `state-change-in-batch` |

# Architecture Diagram


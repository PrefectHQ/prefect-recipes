# AWS recipes

## Airbyte Deployment

- [Airbyte On EC2](airbyte/airbyte-on-ec2/): Deploys Airbyte on an EC2 instance in an autoscaling group.

## AWS Services

- [Delete Default VPCs](aws-services/delete-default-vpcs/): Removes the default VPC across all AWS regions.
- [Basic Network](aws-services/network/): Deploy private networking infrastructure.
- [Terraform State Management](aws-services/state-management/): Deploy infrastructure to host future terraform state files.

## Prefect

- [Docker Agent on EC2](prefect/prefect-agent-on-ec2/): Deploy 1 or more EC2 instances within an Autoscaling Group that will host the Prefect agent.
- [ECS Agent on ECS](prefect/prefect-agent-on-ecs/): Deploy the Prefect agent on AWS Elastic Container Service as a long running service.
- [Kubernetes Agent on EKS](prefect/prefect-agent-on-eks/): A terraform module to deploy an Amazon EKS cluster with the Prefect agent installed.

## Serverless Framework

- [Event Driven Flow](serverless/event-driven-flow/): Lambda for event-driven Prefect flows
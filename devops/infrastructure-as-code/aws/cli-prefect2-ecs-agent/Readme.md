# Prefect Agent on ECS Fargate

## Purpose
This recipe will walk you through the process to create a Prefect Agent using the AWS CLI.

### Notes
- This guide provides an example for creating a role which allows S3 read access, it is likely that your agent will require [additional roles](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_create.html), creation of which is outside the scope of this guide.

## Prerequisites
* [awscli](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
* [prefect](https://docs.prefect.io/getting-started/installation/)


## Steps
1. Create a Service Account in Prefect Cloud
2. Edit the `prefect-agent-td.json` and fill in values for:
   1. `WORK_QUEUE_ID`
   2. `PREFECT_API_KEY`
   3. `PREFECT_API_URL`
3. Optional: Create a role with S3 read permissions to attach to the agent:
   1. `aws iam create-role --role-name PrefectECSRole --assume-role-policy-document file://trust-policy.json`
   2. `aws iam attach-role-policy --policy-arn arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess --role-name PrefectECSRole`
4. Use AWS CLI to [register your task definition](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definitions.html)
    ```
    aws ecs register-task-definition --cli-input-json file://<full_path_to_task_definition_file>/prefect-agent-td.json
    ```
5. Create a service from your task definition, taking care to fill in any network-configuration:
    ```
    aws ecs create-service
    --service-name prefect-agent \
    --task-definition prefect-agent:1 \
    --desired-count 1 \
    --launch-type FARGATE \
    --platform-version LATEST \
    --cluster default \
    --network-configuration "awsvpcConfiguration={subnets=[subnet-12344321],securityGroups=[sg-12344321],assignPublicIp=ENABLED}" \
    --tags key=key1,value=value1 key=key2,value=value2 key=key3,value=value3 \
   --role 
    ```

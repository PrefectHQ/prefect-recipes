# Prefect Agent on ECS Fargate

## Purpose
This recipe will walk you through the process to create a Prefect Agent using the AWS CLI.

### Notes
- This guide does not account for any additional IAM permissions that your agent may need

## Prerequisites
* [awscli]("https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html")
* [prefect](https://docs.prefect.io/getting-started/installation/)

## Steps
1. Create a Service Account in Prefect Cloud
2. Copy the JSON below into a file called `prefect-agent-td.json`
	1. Edit the file and fill in values for:
		1. `WORK_QUEUE_ID`
		2. `PREFECT_API_KEY`
		3. `PREFECT_API_URL`
3. Use AWS CLI to [register your task definition](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definitions.html)
    ```
    aws ecs register-task-definition --cli-input-json file://<full_path_to_task_definition_file>/prefect-agent-td.json
    ```
4. Create a service from your task definition, taking care to fill in any network-configuration:
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

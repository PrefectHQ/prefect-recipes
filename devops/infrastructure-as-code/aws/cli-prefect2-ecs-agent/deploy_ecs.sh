#/bin/bash

# search replace AWS_ACCOUNT_ID with your AWS account ID and adjust the variables below (line 3-7), especially your API key
# if your flow needs access to other AWS resources other than S3, add those in the task role policy: line 96-108
export AWS_REGION=us-east-2
export ECS_CLUSTER_NAME=orionEcsCluster
export ECS_LOG_GROUP_NAME=/ecs/orionEcsAgent
export ECS_SERVICE_NAME=orionECSAgent
export PREFECT_SERVICE_ACCOUNT_KEY=""
export WORK_QUEUE_NAME=default
export ACCOUNT_ID=""
export WORKSPACE_ID=""
export AWS_PAGER=""

# adjust capacity providers to your needs
aws ecs create-cluster --cluster-name $ECS_CLUSTER_NAME --region $AWS_REGION

cat > ecs_tasks_trust_policy.json<<EOL
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "ecs-tasks.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOL

aws iam create-role --role-name orionECSAgentTaskExecutionRole \
--assume-role-policy-document file://ecs_tasks_trust_policy.json --region $AWS_REGION

aws iam attach-role-policy --role-name orionECSAgentTaskExecutionRole \
--policy-arn "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"

cat > ecs_tasks_execution_role.json<<EOL
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ssm:GetParameters"
      ],
      "Resource": "*"
    }
  ]
}
EOL

aws iam put-role-policy --role-name orionECSAgentTaskExecutionRole --policy-name orionECSAgentTaskExecutionRolePolicy --policy-document file://ecs_tasks_execution_role.json


# permissions needed by orion to register new task definitions, deregister old ones, and create new flow runs as ECS tasks
cat > ecs_task_role.json<<EOL
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:CreateSecurityGroup",
                "ec2:CreateTags",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeSubnets",
                "ec2:DescribeVpcs",
                "ec2:DeleteSecurityGroup",
                "ecs:CreateCluster",
                "ecs:DeleteCluster",
                "ecs:DeregisterTaskDefinition",
                "ecs:DescribeClusters",
                "ecs:DescribeTaskDefinition",
                "ecs:DescribeTasks",
                "ecs:ListAccountSettings",
                "ecs:ListClusters",
                "ecs:ListTaskDefinitions",
                "ecs:RegisterTaskDefinition",
                "ecs:RunTask",
                "ecs:StopTask",
                "iam:PassRole",
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "logs:DescribeLogGroups",
                "logs:GetLogEvents",
                "codecommit:PutFile",
                "codecommit:GetObjectIdentifier",
                "codecommit:GetFile",
                "codecommit:GetUploadArchiveStatus",
                "codecommit:GetDifferences",
                "codecommit:GetRepository",
                "codecommit:GetTree",
                "codecommit:GetReferences",
                "codecommit:GetBlob",
                "codecommit:GetCommit",
                "codecommit:BatchGetCommits",
                "codecommit:ListBranches",
                "codecommit:GitPull",
                "codecommit:GetFolder",
                "codecommit:GetBranch"
            ],
            "Resource": "*"
        }
    ]
}
EOL

# adjust it to include permissions needed by your flows
cat > ecs_task_role_s3.json<<EOL
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:*"
      ],
      "Resource": "arn:aws:s3:::*orion*"
    }
  ]
}
EOL

aws iam create-role --role-name orionTaskRole --assume-role-policy-document file://ecs_tasks_trust_policy.json --region $AWS_REGION
aws iam put-role-policy --role-name orionTaskRole --policy-name orionTaskRolePolicy --policy-document file://ecs_task_role.json
aws iam put-role-policy --role-name orionTaskRole --policy-name orionTaskRoleS3Policy --policy-document file://ecs_task_role_s3.json
aws logs create-log-group --log-group-name $ECS_LOG_GROUP_NAME --region $AWS_REGION

# search replace the "AWS_ACCOUNT_ID" below with your AWS account ID. Also, replace or add ECS Agent labels on line 140
cat > orion_ecs_agent_task_definition.json<<EOL
{
    "family": "$ECS_SERVICE_NAME",
    "requiresCompatibilities": [
        "FARGATE"
    ],
    "networkMode": "awsvpc",
    "cpu": "512",
    "memory": "1024",
    "taskRoleArn": "arn:aws:iam::$AWS_ACCOUNT_ID:role/orionTaskRole",
    "executionRoleArn": "arn:aws:iam::$AWS_ACCOUNT_ID:role/orionECSAgentTaskExecutionRole",
    "containerDefinitions": [
        {
            "name": "$ECS_SERVICE_NAME",
            "image": "prefecthq/prefect:2-latest",
            "essential": true,
            "command": [
                "prefect",
                "agent",
                "start",
                "-q",
                "$WORK_QUEUE_NAME"
            ],
            "environment": [
                {
                    "name": "PREFECT_API_KEY",
                    "value": "$PREFECT_SERVICE_ACCOUNT_KEY"
                },
                {
                    "name": "PREFECT_API_URL",
                    "value": "https://api.prefect.cloud/api/accounts/$ACCOUNT_ID/workspaces/$WORKSPACE_ID"
                },
                {
                    "name": "PREFECT_LOGGING_LEVEL",
                    "value": "INFO"
                }
            ],
            "logConfiguration": {
                "logDriver": "awslogs",
                "options": {
                    "awslogs-group": "$ECS_LOG_GROUP_NAME",
                    "awslogs-region": "$AWS_REGION",
                    "awslogs-stream-prefix": "ecs",
                    "awslogs-create-group": "true"
                }
            }
        }
    ]
}
EOL

aws ecs register-task-definition --cli-input-json file://orion_ecs_agent_task_definition.json --region $AWS_REGION

export VPC=$(aws ec2 describe-vpcs --filters Name=is-default,Values=true)
export VPC_ID=$(echo $VPC | jq -r '.Vpcs | .[0].VpcId')
SUBNETS=$(aws ec2 describe-subnets --filters Name=vpc-id,Values=$VPC_ID --region $AWS_REGION)
export SUBNET1=$(echo $SUBNETS | jq -r '.Subnets | .[0].SubnetId')
export SUBNET2=$(echo $SUBNETS | jq -r '.Subnets | .[1].SubnetId')
export SUBNET3=$(echo $SUBNETS | jq -r '.Subnets | .[2].SubnetId')

aws ecs create-service \
    --service-name $ECS_SERVICE_NAME\
    --task-definition $ECS_SERVICE_NAME:1 \
    --desired-count 1 \
    --launch-type FARGATE \
    --platform-version LATEST \
    --cluster $ECS_CLUSTER_NAME \
    --network-configuration awsvpcConfiguration="{subnets=[$SUBNET1, $SUBNET2, $SUBNET3],assignPublicIp=ENABLED}" --region $AWS_REGION
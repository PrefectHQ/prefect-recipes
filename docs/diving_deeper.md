# Diving Deeper 🍱

## Data Engineering / DataOps
- [Serverless Real-Time Data Pipelines on AWS with Prefect, ECS and GitHub Actions](https://medium.com/the-prefect-blog/serverless-real-time-data-pipelines-on-aws-with-prefect-ecs-and-github-actions-1737c80da3f5)

## ELT/ETL
- [Export Airbyte Configuration and Load to S3 bucket using blocks, including Python-based deployment](./flows-advanced/etl/export-airbyte-config-and-write-to-s3-bucket-using-blocks.py)
- [ELT with Snowflake Using Async and Blocks](./flows-advanced/etl/elt-with-snowflake.py)

## AWS Infrastructure
- [Deploy a Prefect agent to ECS using the AWS CLI](./devops/infrastructure-as-code/aws/cli-prefect2-ecs-agent/)
- [Deploy a Prefect agent to ECS with Terraform](./devops/infrastructure-as-code/aws/tf-prefect2-ecs-agent/)
- [Deploy Flows Using ECSTask Infrastructure Blocks](https://towardsdatascience.com/prefect-aws-ecs-fargate-github-actions-make-serverless-dataflows-as-easy-as-py-f6025335effc)

## Azure Infrastructure
- [Setup Azure with Prefect](./devops/infrastructure-as-code/azure/setup-azure-with-prefect/)
- [Deploy Prefect Orion to an AKS Cluster with Azure Blob Storage](./devops/infrastructure-as-code/azure/prefect-agent-on-aks/)
- [Setup an Azure VM and Run the Prefect Agent](./devops/infrastructure-as-code/azure/prefect-agent-on-avm/)

## Github Actions
- [Build flow image and Prefect deployment with storage and infra Blocks on push to branch](./devops/github-actions/general-docker-deploy.yaml)
- [Build and Push flow docker image to Google Artifact Registry](./devops/github-actions/docker-build-push-gcp-artifact-registry.yaml)
- [Build / Apply prefect deployment with blocks on change to python files](./devops/github-actions/minimal-prefect-deployment-build.yaml)
- [Automate Prefect Deployments to AWS ECS Fargate Using GitHub Actions](https://github.com/anna-geller/dataflow-ops)

## Dockerfiles
- [Build an image from the latest Python 3.9 base image and your `requirements.txt`](./devops/dockerfiles/Dockerfile.latest_python_3dot9)

## Django
- [Using Django with Prefect 2](https://github.com/abrookins/django-prefect-example)

## Prefect 1.0 Legacy
- [Register a Prefect Flow](./prefect-v1-legacy/devops/github-actions/)
- [Run GraphQL Queries](./prefect-v1-legacy/graphql-queries/)
- [Airbyte Orchestration](./prefect-v1-legacy/use-cases/airbyte-orchestration/)
- [ETL with AWS S3 and Snowflake](./prefect-v1-legacy/use-cases/etl-s3-to-snowflake/)
- [Use AWS Lambda for Event-Driven Flows](./prefect-v1-legacy/use-cases/event-driven-triggers/)
- [Read Secrets into Prefect Cloud tenant](./prefect-v1-legacy/use-cases/import-secrets-to-cloud/)
- [Handle DBT Model Failures](./prefect-v1-legacy/use-cases/rerun_dbt_models_from_failure/)
- [S3 Flow Storage on EKS](./prefect-v1-legacy/use-cases/s3-flow-storage-on-eks/)
- [Use LocalExecutor to run Dask computations on a Coiled cluster](https://docs.coiled.io/user_guide/examples/prefect.html#using-the-localexecutor)
- [Use DaskExecutor to run Prefect tasks in parallel on a Coiled cluster](https://docs.coiled.io/user_guide/examples/prefect.html#using-the-daskexecutor)

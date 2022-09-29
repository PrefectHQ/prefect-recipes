<div align="center">
  <a href="https://github.com/PrefectHQ/prefect-recipes">
    <img src="imgs/chef_marvin_by_dalle.png" alt="Logo" width="200">
  </a>
</div>

# Prefect Recipes 🧑‍🍳 🥐

This repository contains common and extensible Prefect patterns to drive efficient workflows &mdash; we like to call these patterns [our **recipes**](#table-of-contents-)!

Here you'll find starter code and more advanced example use cases.

## Contributing = Swag 🧢
We're always looking for new contributions! Check out [Contributions](#contributions) to learn how you can add your Prefect 2.0 recipe and earn some swag!

## Issues / Bugs 🐛
To report issues, typos, or link fixes, please [open an issue.](https://github.com/PrefectHQ/prefect-recipes/issues/new?assignees=&labels=i%3A+bug&template=bug_report.yaml&title=%5BBug%5D%3A+) We appreciate it!

## Recipe Requests 👩‍🍳
What are you interested in seeing examples of? [Jot down your big idea here.](https://github.com/PrefectHQ/prefect-recipes/issues/new?assignees=&labels=i%3A+enhancement&template=feature_request.yaml)

## Table of Contents 📖
- [Getting Started](#getting-started-)
  - [Subflows](#subflows)
  - [Control Flow](#control-flow)
  - [Optimization](#optimization)
  - [Notifications](#notifications)
  - [Flow Run Observability](#flow-run-observability)
  - [Parameters](#parameters)
  - [Testing](#testing)
  - [Triggering Flow Runs](#triggering-flow-runs)
  - [Deployments](#deployments)

- [Diving Deeper](#diving-deeper-)
  - [Data Engineering / DataOps](#data-engineering--dataops)
  - [AWS Infrastructure](#aws-infrastructure)
  - [Azure Infrastructure](#azure-infrastructure)
  - [GitHub Actions](#github-actions)
  - [Legacy (Prefect 1.0)](#prefect-10-legacy)
- [Issues & Bugs](#issues--bugs-)
- [Recipe Requests](#recipe-requests-)
- [Contributions](#contributions)
- [Join the Discussion](#join-our-discussions-%EF%B8%8F)
- [Thanks](#thanks-)

## Getting Started 🍯
#### Subflows
- [Getting Started With Subflows](https://discourse.prefect.io/t/migrating-to-prefect-2-0-from-flow-of-flows-to-subflows/1318)
- [Run Multiple Subflows or Child Flows in Parallel](https://discourse.prefect.io/t/how-can-i-run-multiple-subflows-or-child-flows-in-parallel/96)
- [Subflow with a Different Task Runner Than Parent Flow](https://discourse.prefect.io/t/can-my-subflow-use-a-different-task-runner-than-my-parent-flow/101)
- [Create a Subflow and Block Until It's Completed](https://discourse.prefect.io/t/how-can-i-create-a-subflow-and-block-until-it-s-completed/94)

#### Control Flow
- [Conditionally Stop a Task Run](https://discourse.prefect.io/t/how-can-i-stop-the-task-run-based-on-a-custom-logic/83)
- [Ensure Tasks Immediately Fail If Upstream Task Fails](https://discourse.prefect.io/t/how-to-ensure-that-my-tasks-immediately-fail-if-a-specific-upstream-task-failed/111)
- [Define State Dependencies Between Tasks](https://discourse.prefect.io/t/how-can-i-define-state-dependencies-between-tasks/69/2)

#### Optimization
- [Cache a Task Result To Prevent Recomputation](https://discourse.prefect.io/t/how-can-i-cache-a-task-result-for-two-hours-to-prevent-re-computation/67)

#### Notifications
- [Send Notifications with a Slack Webhook](https://discourse.prefect.io/t/sending-notifications-in-cloud-1-0-using-automations-cloud-2-0-slack-webhook-blocks-and-notifications/1315)

#### Flow Run Observability
- [Interact with REST API](https://discourse.prefect.io/t/how-can-i-interact-with-the-backend-api-using-a-python-client/80)
- [Determine Whether a Flow Run Was Executed Ad Hoc or on a Schedule](https://discourse.prefect.io/t/how-can-i-determine-whether-a-flow-run-has-been-executed-ad-hoc-or-was-running-on-schedule/120)

#### Parameters
- [Use flow parameters](https://discourse.prefect.io/t/guide-to-implementing-parameters-between-prefect-1-0-and-2-0/1321)

#### Testing
- [Testing Flows, Subflows, and Tasks](https://discourse.prefect.io/t/unit-testing-best-practices-for-prefect-flows-subflows-and-tasks/1070/2)

#### Triggering Flow Runs
- [Triggering Flow Runs From a Deployment via API Call or From a Terminal Using Curl](https://discourse.prefect.io/t/how-to-trigger-a-flow-run-from-a-deployment-via-api-call-using-python-requests-library-or-from-a-terminal-using-curl/1396)

#### Deployments
- [Deploy Flows to Run as a Local Process, Docker Container or a Kubernetes Job](https://discourse.prefect.io/t/how-to-deploy-prefect-2-0-flows-to-run-as-a-local-process-docker-container-or-a-kubernetes-job/1246)
- [Deploy Flows to AWS](https://discourse.prefect.io/t/how-to-deploy-prefect-2-0-flows-to-aws/1252)
- [Deploy Flows to GCP](https://discourse.prefect.io/t/how-to-deploy-prefect-2-0-flows-to-gcp/1251)
- [Deploy Flows to Azure](https://discourse.prefect.io/t/how-to-deploy-prefect-2-0-flows-to-azure/1312)
- [Use Docker Container as an Infrastructure and GitHub as a Storage](https://towardsdatascience.com/create-robust-data-pipelines-with-prefect-docker-and-github-12b231ca6ed2)
- [Python-Based Deployments](https://discourse.prefect.io/t/prefect-2-1-0-has-just-arrived-it-includes-python-based-deployments-improvements-to-work-queues-tons-of-new-integrations-and-features/1422)

## Diving Deeper 🍱
#### Data Engineering / DataOps
- [Serverless Real-Time Data Pipelines on AWS with Prefect, ECS and GitHub Actions](https://medium.com/the-prefect-blog/serverless-real-time-data-pipelines-on-aws-with-prefect-ecs-and-github-actions-1737c80da3f5)

#### ELT/ETL
- [Export Airbyte Configuration and Load to S3 bucket using blocks, including Python-based deployment](./flows-advanced/etl/export-airbyte-config-and-write-to-s3-bucket-using-blocks.py)
- [ELT with Snowflake Using Async and Blocks](./flows-advanced/etl/elt-with-snowflake.py)

#### AWS Infrastructure
- [Deploy a Prefect agent to ECS using the AWS CLI](./devops/infrastructure-as-code/aws/cli-prefect2-ecs-agent/)
- [Deploy a Prefect agent to ECS with Terraform](./devops/infrastructure-as-code/aws/tf-prefect2-ecs-agent/)

#### Azure Infrastructure
- [Setup Azure with Prefect](./video-demos/setup-azure-with-prefect/)
- [Deploy Prefect Orion to an AKS Cluster with Azure Blob Storage](./devops/infrastructure-as-code/azure/prefect-agent-on-aks/)
- [Setup an Azure VM and Run the Prefect Agent](./devops/infrastructure-as-code/azure/prefect-agent-on-avm/)

#### Github Actions
- [Build flow image and Prefect deployment with storage and infra Blocks on push to branch](./devops/github-actions/general-docker-deploy.yaml)
- [Build and Push flow docker image to Google Artifact Registry](./devops/github-actions/docker-build-push-gcp-artifact-registry.yaml)
- [Build / Apply prefect deployment with blocks on change to python files](./devops/github-actions/minimal-prefect-deployment-build.yaml)

#### Dockerfiles
- [Build an image from the latest Python 3.9 base image and your `requirements.txt`](./devops/dockerfiles/Dockerfile.latest_python_3dot9)

#### Prefect 1.0 Legacy
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

## Join our discussions 🗣️
We use our [Slack Community](https://www.prefect.io/slack) and [Discourse](https://discourse.prefect.io/c/21) to discuss all things Prefect-- such as FAQ, use cases and integrations. Join in the conversation :smile:

## Contributions
We're always looking for new contributions! You can add your Prefect 2.0 recipe and earn some swag in a few simple steps:

1. Look through the recipes to ensure your example is unique
2. Clone the prefect-recipes repo:
```console
git clone git@github.com:PrefectHQ/prefect-recipes.git
```
3. Create and checkout a new branch:
```console
git branch feat/recipe-name
git checkout feat/recipe-name
```
5. Add your code under the appropriate category, making sure it is reproducible and easy to understand.
6. Add your recipe to README.
7. Commit and push the code to your remote branch.
8. Create a PR 🤌 

## Thanks 💙
Thank you for your contributions and efforts to improve prefect-recipes. We're glad to have you in our community!

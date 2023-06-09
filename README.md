<div align="center">
  <a href="https://github.com/PrefectHQ/prefect-recipes">
    <img src="./docs/imgs/chef-marvin-by-dalle.png" alt="Logo" width="200">
  </a>
</div>

# Prefect Recipes 🧑‍🍳 🥐

This repository contains common and extensible Prefect patterns to drive efficient workflows &mdash; we like to call these patterns our **recipes**

Here you'll find starter code and more advanced example use cases.

## Contributing = Swag 🧢
We're always looking for new contributions! See our existing [Recipe Ideas/Issues](https://github.com/PrefectHQ/prefect-recipes/issues) for inspiration. Read a detailed guide on [how to share your solutions with the Prefect community](https://docs.prefect.io/recipes/contribute-recipes/)  or [run these commands](#contributions) to get started right away.

## Issues / Bugs 🐛
To report issues, typos, or link fixes, please [open an issue.](https://github.com/PrefectHQ/prefect-recipes/issues/new?assignees=&labels=i%3A+bug&template=bug_report.yaml&title=%5BBug%5D%3A+) We appreciate it!

## Recipe Ideas 👩‍🍳
What are you interested in seeing examples of? [Jot down your big idea here.](https://github.com/PrefectHQ/prefect-recipes/issues/new?assignees=&labels=i%3A+enhancement&template=feature_request.yaml)

## Table of Contents 📖
- [Getting Started](#getting-started-)
  - [Introductory Videos](#introductory-videos)
  - [Subflows](#subflows)
  - [Control Flow](#control-flow)
  - [Optimization](#optimization)
  - [Notifications](#notifications)
  - [Flow Run Observability](#flow-run-observability)
  - [Configuration (Using Blocks](#configuration-using-blocks)
  - [Parameters](#parameters)
  - [Testing](#testing)
  - [Triggering Flow Runs](#triggering-flow-runs)
  - [Flow Deployment](#flow-deployment)

- [Diving Deeper](#diving-deeper-)
  - [Deployments & CICD](#deployments--cicd)
  - [Streaming & Event-Driven Workflows](#streaming--event-driven-workflows)
  - [Serverless](#serverless)
  - [Data Engineering / DataOps](#data-engineering--dataops)
  - [ELT/ETL](#eltetl)
  - [AWS Infrastructure](#aws-infrastructure)
  - [Azure Infrastructure](#azure-infrastructure)
  - [Helm](#helm)
  - [Kubernetes](#kubernetes)
  - [GitHub Actions](#github-actions)
  - [Dockerfiles](#dockerfiles)
  - [Django](#django)
  - [Pydantic](#pydantic)
  - [Hex](#hex)
  - [Product](#product)
  - [Data Science](#data-science)
  - [Modular Data Stack](#modular-data-stack)
  - [Miscellaneous](#miscellaneous)
  - [Legacy (Prefect 1.0)](#prefect-10-legacy)
- [Issues & Bugs](#issues--bugs-)
- [Contributions](#contributions)
- [Join the Discussion](#join-our-discussions-%EF%B8%8F)
- [Thanks](#thanks-)

## Getting Started 🍯
#### Introductory Videos
- [What is Prefect?](https://www.youtube.com/watch?v=ZK1s8OfVSpY)
- [Prefect Demo](https://www.youtube.com/watch?v=-MC-TLDbJ1U)
- [Getting Started with Prefect Cloud](https://www.youtube.com/watch?v=vOpmE5w0XuU&t=1s)

#### Subflows
- [Getting Started With Subflows](https://discourse.prefect.io/t/migrating-to-prefect-2-0-from-flow-of-flows-to-subflows/1318)
- [Run Multiple Subflows or Child Flows in Parallel](https://discourse.prefect.io/t/how-can-i-run-multiple-subflows-or-child-flows-in-parallel/96)
- [Subflow with a Different Task Runner Than Parent Flow](https://discourse.prefect.io/t/can-my-subflow-use-a-different-task-runner-than-my-parent-flow/101)
- [Create a Subflow and Block Until It's Completed](https://discourse.prefect.io/t/how-can-i-create-a-subflow-and-block-until-it-s-completed/94)
- [Running Subflows On Their Own Infrastructure Using a Separate Deployment](./flows-advanced/parent-orchestrator/pokemon_weight.py)

#### Control Flow
- [Conditionally Stop a Task Run](https://discourse.prefect.io/t/how-can-i-stop-the-task-run-based-on-a-custom-logic/83)
- [Ensure Tasks Immediately Fail If Upstream Task Fails](https://discourse.prefect.io/t/how-to-ensure-that-my-tasks-immediately-fail-if-a-specific-upstream-task-failed/111)
- [Define State Dependencies Between Tasks](https://discourse.prefect.io/t/how-can-i-define-state-dependencies-between-tasks/69/2)

#### Optimization
- [Cache a Task Result To Prevent Recomputation](https://discourse.prefect.io/t/how-can-i-cache-a-task-result-for-two-hours-to-prevent-re-computation/67)

#### Notifications
- [Send Notifications with a Slack Webhook](https://discourse.prefect.io/t/sending-notifications-in-cloud-1-0-using-automations-cloud-2-0-slack-webhook-blocks-and-notifications/1315)
- [Sending Slack Notifications in Python with Prefect](https://medium.com/the-prefect-blog/sending-slack-notifications-in-python-with-prefect-840a895f81c)

#### Flow Run Observability
- [Interact with REST API](https://discourse.prefect.io/t/how-can-i-interact-with-the-backend-api-using-a-python-client/80)
- [Determine Whether a Flow Run Was Executed Ad Hoc or on a Schedule](https://discourse.prefect.io/t/how-can-i-determine-whether-a-flow-run-has-been-executed-ad-hoc-or-was-running-on-schedule/120)

#### Configuration (using Blocks)
- [Supercharge your Python Code with Blocks - Blog](https://medium.com/the-prefect-blog/supercharge-your-python-code-with-blocks-ca8a58128c55)
- [Supercharge your Python Code with Blocks - Video](https://www.youtube.com/watch?v=sR9fNHfOETw)

#### Parameters
- [Use flow parameters](https://discourse.prefect.io/t/guide-to-implementing-parameters-between-prefect-1-0-and-2-0/1321)

#### Testing
- [Testing Flows, Subflows, and Tasks](https://discourse.prefect.io/t/unit-testing-best-practices-for-prefect-flows-subflows-and-tasks/1070/2)

#### Logging
- [Explain Your Python Exceptions with OpenAI](https://medium.com/the-prefect-blog/explain-your-python-exceptions-with-openai-b41a69b3d436)

#### Triggering Flow Runs
- [Trigger a deployment run when new files land in S3 Event Notifications with EventBridge](/devops/infrastructure-as-code/aws/s3-eventbridge/)
- [Triggering Flow Runs From a Deployment via API Call or From a Terminal Using Curl](https://discourse.prefect.io/t/how-to-trigger-a-flow-run-from-a-deployment-via-api-call-using-python-requests-library-or-from-a-terminal-using-curl/1396)
- [Event-Driven Data Pipelines with AWS Lambda and GitHub Actions](https://medium.com/the-prefect-blog/event-driven-data-pipelines-with-aws-lambda-prefect-and-github-actions-b3d9f84b1309)

#### Flow Deployment
- [Deploy Flows to Run as a Local Process, Docker Container or a Kubernetes Job](https://discourse.prefect.io/t/how-to-deploy-prefect-2-0-flows-to-run-as-a-local-process-docker-container-or-a-kubernetes-job/1246)
- [Deploy Flows to AWS](https://discourse.prefect.io/t/how-to-deploy-prefect-2-0-flows-to-aws/1252)
- [Deploy Flows to GCP](https://discourse.prefect.io/t/how-to-deploy-prefect-2-0-flows-to-gcp/1251)
- [Deploy Flows to Azure](https://discourse.prefect.io/t/how-to-deploy-prefect-2-0-flows-to-azure/1312)
- [Store Flows in GitHub and Execute in a Docker Container](https://towardsdatascience.com/create-robust-data-pipelines-with-prefect-docker-and-github-12b231ca6ed2)
- [Python-Based Deployments](https://discourse.prefect.io/t/prefect-2-1-0-has-just-arrived-it-includes-python-based-deployments-improvements-to-work-queues-tons-of-new-integrations-and-features/1422)

## Diving Deeper 🍱
#### Deployments & CICD
- [Scheduled Data Pipelines in 5 Minutes with Prefect and GitHub Actions - Blog](https://medium.com/the-prefect-blog/scheduled-data-pipelines-in-5-minutes-with-prefect-and-github-actions-39a5e4ab03f4)
    - [Scheduling: Get started with Prefect by scheduling your Prefect flows with GitHub Actions - GitHub Repo](https://github.com/anna-geller/prefect-getting-started)
- [Declarative Dataflow Deployments with Prefect Make CI/CD a Breeze](https://medium.com/the-prefect-blog/declarative-dataflow-deployments-with-prefect-make-ci-cd-a-breeze-fe77bdbb58d4)
- [Deploy Prefect Pipelines with Python: Perfect!](https://medium.com/the-prefect-blog/deploy-prefect-pipelines-with-python-perfect-68c944a3a89f)
- [Prefect Deployments FAQ (PDF) - DataflowOps for Prefect 2.0](https://discourse.prefect.io/t/prefect-deployments-faq-pdf/1467)
- [GCP and Prefect Cloud — from Docker Container to Cloud VM on Google Compute Engine](https://medium.com/the-prefect-blog/gcp-and-prefect-cloud-from-docker-container-to-cloud-vm-on-google-compute-engine-2dffa026d16b)
    - [GCP: Repository template to get started with Prefect Cloud & Google Cloud - GitHub Repo](https://github.com/anna-geller/prefect-cloud-gcp)
- [Deployment patterns & examples: Code examples showing flow deployment to various types of infrastructure - GitHub Repo](https://github.com/anna-geller/prefect-deployment-patterns)
- [Docker: How to use Prefect Deployments with flow code baked into a Docker image - GitHub Repo](https://github.com/anna-geller/prefect-docker-deployment)
- [AWS Fargate: Project demonstrating how to automate Prefect 2.0 deployments to AWS ECS Fargate - GitHub Repo](https://github.com/anna-geller/dataflow-ops)
- [AWS EKS: Project demonstrating how to automate Prefect 2.0 deployments to AWS EKS - GitHub Repo](https://github.com/anna-geller/dataflow-ops-aws-eks)

#### Streaming & Event-Driven Workflows
- [Event-driven Data Pipelines with AWS Lambda, Prefect and GitHub Actions](https://medium.com/the-prefect-blog/event-driven-data-pipelines-with-aws-lambda-prefect-and-github-actions-b3d9f84b1309)
    - [Streaming: Example project demonstrating deployment patterns for real-time streaming workflows with Prefect 2.0 - GitHub Repo](https://github.com/anna-geller/prefect-streaming)
- [Scheduled vs. Event-driven Data Pipelines — Orchestrate Anything with Prefect](https://medium.com/the-prefect-blog/scheduled-vs-event-driven-data-pipelines-orchestrate-anything-with-prefect-b915e6adc3ba)
- [You No Longer Need Two Separate Systems for Batch Processing and Streaming](https://www.prefect.io/guide/blog/you-no-longer-need-two-separate-systems-for-batch-processing-and-streaming/)

#### Serverless
- [GCP: Serverless Prefect Flows with Google Cloud Run Jobs](https://medium.com/the-prefect-blog/serverless-prefect-flows-with-google-cloud-run-jobs-23edbf371175)
- [Azure: Serverless Prefect Flows with Azure Container Instances](https://medium.com/the-prefect-blog/serverless-prefect-flows-with-azure-container-instances-f2442ebc9343)
- [AWS: Prefect + AWS ECS Fargate + GitHub Actions Make Serverless Dataflows As Easy as .py](https://medium.com/towards-data-science/prefect-aws-ecs-fargate-github-actions-make-serverless-dataflows-as-easy-as-py-f6025335effc)
- [AWS Lambda: Deploy a Prefect flow to serverless AWS Lambda function - GitHub Repo](https://github.com/anna-geller/prefect-aws-lambda)

#### Data Engineering / DataOps
- [Serverless Real-Time Data Pipelines on AWS with Prefect, ECS and GitHub Actions](https://medium.com/the-prefect-blog/serverless-real-time-data-pipelines-on-aws-with-prefect-ecs-and-github-actions-1737c80da3f5)
- [Build a Data Platform with Prefect, dbt, and Snowflake (using blocks)](https://github.com/anna-geller/prefect-dataplatform)
- [Real World Python for Data Engineering - Supercharge Your Data Orchestration with Prefect 2.0](https://medium.com/@danilo.drobac/6-supercharge-your-data-orchestration-with-prefect-2-0-b6827618b340)
- [Create a Maintainable Data Pipeline with Prefect and DVC](https://towardsdatascience.com/create-a-maintainable-data-pipeline-with-prefect-and-dvc-1d691ea5bcea)
- [Data engineering & orchestration with Prefect, Docker, Terraform, Google CloudRun, BigQuery and Streamlit](https://medium.com/@ryanelamb/a-data-engineering-project-with-prefect-docker-terraform-google-cloudrun-bigquery-and-streamlit-3fc6e08b9398)

#### ELT/ETL
- [Orchestrating Airbyte with Prefect 2](https://medium.com/the-prefect-blog/orchestrating-airbyte-with-prefect-2-0-35501997a974)
- [Coordinate ELT in 2023 with Airbyte, dbt and Prefect](https://medium.com/the-prefect-blog/coordinate-elt-in-2023-with-airbyte-dbt-and-prefect-ecd7547e6c1a)
- [Schedule & orchestrate dbt Cloud jobs with Prefect](https://medium.com/the-prefect-blog/schedule-orchestrate-dbt-cloud-jobs-with-prefect-b64c3b7f2a02)
- [Prefect & Fivetran: integrate all the tools & orchestrate them in Python](https://medium.com/the-prefect-blog/prefect-fivetran-integrate-all-the-tools-orchestrate-them-in-python-4195099487ae)
- [Export Airbyte Configuration and Load to S3 bucket using blocks, including Python-based deployment](./flows-advanced/etl/export-airbyte-config-and-write-to-s3-bucket-using-blocks.py)
- [ELT with Snowflake Using Async and Blocks](./flows-advanced/etl/elt-with-snowflake.py)

#### AWS Infrastructure
- [Deploy a Prefect agent to ECS using the AWS CLI](./devops/infrastructure-as-code/aws/cli-prefect2-ecs-agent/)
- [Deploy a Prefect agent to ECS with Terraform](./devops/infrastructure-as-code/aws/tf-prefect2-ecs-agent/)
- [Deploy Flows Using ECSTask Infrastructure Blocks](https://towardsdatascience.com/prefect-aws-ecs-fargate-github-actions-make-serverless-dataflows-as-easy-as-py-f6025335effc)
- [Deploy a Prefect agent to ECS Fargate using CloudFormation and GitHub Actions](https://youtu.be/Eemq2X9XrlE)

#### Azure Infrastructure
- [Setup Azure with Prefect](./devops/infrastructure-as-code/azure/setup-azure-with-prefect/)
- [Deploy Prefect Orion to an AKS Cluster with Azure Blob Storage](./devops/infrastructure-as-code/azure/prefect-agent-on-aks/)
- [Setup an Azure VM and Run the Prefect Agent](./devops/infrastructure-as-code/azure/prefect-agent-on-avm/)
- [Deploy Flows Using Azure Container Instances Infrastructure Blocks](https://medium.com/the-prefect-blog/serverless-prefect-flows-with-azure-container-instances-f2442ebc9343)

#### GCP Infrastructure
- [Setup GCP Managed Instance Group with Prefect](./devops/infrastructure-as-code/gcp/prefect2-mig/)

#### Helm
- [Deploy Prefect Agent using Helm and Terraform](./devops/infrastructure-as-code/helm/prefect2-agent/)

#### Kubernetes
- [How to use Kubernetes with Prefect](https://medium.com/the-prefect-blog/how-to-use-kubernetes-with-prefect-419b2e8b8cb2)
- [How to use Kubernetes with Prefect: Part 2](https://medium.com/the-prefect-blog/how-to-use-kubernetes-with-prefect-part-2-2e98cdb91c7e)
- [How to use Kubernetes with Prefect: Part 3](https://medium.com/the-prefect-blog/how-to-use-kubernetes-with-prefect-part-3-e2223ce34ba7)

#### Github Actions
- [Automate Prefect Deployments to AWS ECS Fargate Using GitHub Actions](https://github.com/anna-geller/dataflow-ops)
- [Automate Python-Based Deployments with GitHub Actions](https://github.com/radbrt/orion_flows)
- [Build / Apply prefect deployment with blocks on change to python files](./devops/github-actions/minimal-prefect-deployment-build.yaml)
- [Build and Push flow docker image to Google Artifact Registry](./devops/github-actions/docker-build-push-gcp-artifact-registry.yaml)
- [Build flow image and Prefect deployment with storage and infra Blocks on push to branch](./devops/github-actions/general-docker-deploy.yaml)
- [Conditionally deploy Prefect flow(s) only when flow-related files have changed](./devops/github-actions/prefect-deploy-only-when-files-change-no-docker-build.yaml)
- [Conditionally build a docker image & deploy Prefect flow(s) only when flow-related files have changed](./devops/github-actions/prefect-deploy-only-when-files-change-including-docker-build.yaml)

#### Django
- [Using Django with Prefect 2](https://github.com/abrookins/django-prefect-example)

#### Pydantic
- [Using Pydantic BaseModel with Prefect 2](https://discourse.prefect.io/t/use-pydantic-to-ensure-data-consistency/1815)
- [Build a Full-Stack ML Application With Pydantic And Prefect](https://towardsdatascience.com/build-a-full-stack-ml-application-with-pydantic-and-prefect-915f00fe0c62?sk=b1f8c5cb53a6a9d7f48d66fa778e9cf0)

#### Hex
- [Create Observable and Reproducible Notebooks with Hex - Article](https://towardsdatascience.com/create-observable-and-reproducible-notebooks-with-hex-460e75818a09)
- [Create Observable and Reproducible Notebooks with Hex - Video](https://youtu.be/_BjqCrun4nE)

#### Product
- [(Re)Introducing Prefect: The Global Coordination Plane](https://www.prefect.io/guide/blog/the-global-coordination-plane/)
- [The Dataflow Coordination Spectrum](https://www.prefect.io/guide/blog/the-dataflow-coordination-spectrum/)
- [Why Prefect?](https://www.prefect.io/guide/blog/why-prefect/)
- [Workflow Orchestration vs. Data Orchestration — Are Those Different?](https://towardsdatascience.com/workflow-orchestration-vs-data-orchestration-are-those-different-a661c46d2e88)
- [Dataflow Design Patterns](https://www.prefect.io/guide/blog/dataflow-design-patterns/)

#### Data Science
- [How to Structure an ML Project for Reproducibility and Maintainability](https://towardsdatascience.com/how-to-structure-an-ml-project-for-reproducibility-and-maintainability-54d5e53b4c82)
- [Orchestrate Your Data Science Project with Prefect 2.0](https://medium.com/the-prefect-blog/orchestrate-your-data-science-project-with-prefect-2-0-4118418fd7ce)
- [Build a Full-Stack ML Application With Pydantic And Prefect](https://towardsdatascience.com/build-a-full-stack-ml-application-with-pydantic-and-prefect-915f00fe0c62)

#### Modular Data Stack
- [How to Build a Modular Data Stack — Data Platform with Prefect, dbt and Snowflake](https://medium.com/the-prefect-blog/how-to-build-a-modular-data-stack-data-platform-with-prefect-dbt-and-snowflake-89f928974e85)
- [How to Build Modular Dataflows with Tasks, Flows and Subflows in Prefect](https://medium.com/the-prefect-blog/how-to-build-modular-dataflows-with-tasks-flows-and-subflows-in-prefect-5eaabdfbb70e)

#### Miscellaneous
- [Merge Dependabot Pull Requests with Prefect 2 & a GitHubCredentials block](./flows-advanced/merge_dependabot_pull_requests.py)

#### Discourse
[Prefect Agents and Work-Queues FAQ](https://discourse.prefect.io/t/agents-and-work-queues-faq/1468)

#### Prefect 1.0 Legacy
- [Register a Prefect 1 Flow](./prefect-v1-legacy/devops/github-actions/)
- [Run GraphQL Queries](./prefect-v1-legacy/graphql-queries/)
- [Airbyte Orchestration](./prefect-v1-legacy/use-cases/airbyte-orchestration/)
- [ETL with AWS S3 and Snowflake](./prefect-v1-legacy/use-cases/etl-s3-to-snowflake/)
- [Use AWS Lambda for Event-Driven Flows](./prefect-v1-legacy/use-cases/event-driven-triggers/)
- [Read Secrets into Prefect 1 Cloud tenant](./prefect-v1-legacy/use-cases/import-secrets-to-cloud/)
- [Handle DBT Model Failures](./prefect-v1-legacy/use-cases/rerun_dbt_models_from_failure/)
- [S3 Prefect 1 Flow Storage on EKS](./prefect-v1-legacy/use-cases/s3-flow-storage-on-eks/)
- [Use LocalExecutor to run Dask computations on a Coiled cluster](https://docs.coiled.io/user_guide/examples/prefect.html#using-the-localexecutor)
- [Use DaskExecutor to run Prefect 1 tasks in parallel on a Coiled cluster](https://docs.coiled.io/user_guide/examples/prefect.html#using-the-daskexecutor)

## Contributions
We're always looking for new contributions! You can add your Prefect 2.0 recipe and earn some swag in a few simple steps:

1. Clone the prefect-recipes repo:
```console
git clone git@github.com:PrefectHQ/prefect-recipes.git
```
2. Create and checkout a new branch:
```console
git checkout -b feat/new-recipe-name
```
3. Add your code under the appropriate category. Unsure? Add it under `flows-advanced/`.
4. Add your recipe to this README.
5. Commit and push the code to your remote branch.
6. Create a PR 🤌 

## Join our discussions 🗣️
We use our [Slack Community](https://www.prefect.io/slack) and [Discourse](https://discourse.prefect.io/c/21) to discuss all things Prefect-- such as FAQ, use cases and integrations. Join in the conversation :smile:

## Thanks 💙
Thank you for your contributions and efforts to improve prefect-recipes. We're glad to have you in our community!

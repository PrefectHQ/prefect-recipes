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

- [Diving Deeper](#diving-deeper-)
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
  - [Data Science](#data-science)
  - [Modular Data Stack](#modular-data-stack)
  - [Miscellaneous](#miscellaneous)
- [Issues & Bugs](#issues--bugs-)
- [Contributions](#contributions)
- [Join the Discussion](#join-our-discussions-%EF%B8%8F)
- [Thanks](#thanks-)

## Getting Started 🍯
#### Introduction
- [What is Prefect?](https://www.prefect.io/blog/intro-to-workflow-orchestration)
- [An Introduction to Your First Prefect Flow](https://www.youtube.com/watch?v=4yIW34WcmBQ)

#### Subflows
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
- [Triggering Flow Runs From a Deployment via API Call or From a Terminal Using Curl](https://discourse.prefect.io/t/how-to-trigger-a-flow-run-from-a-deployment-via-api-call-using-python-requests-library-or-from-a-terminal-using-curl/1396)

## Diving Deeper 🍱

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

#### Github Actions
- [Conditionally deploy Prefect flow(s) only when flow-related files have changed](./devops/github-actions/prefect-deploy-only-when-files-change-no-docker-build.yaml)
- [Conditionally build a docker image & deploy Prefect flow(s) only when flow-related files have changed](./devops/github-actions/prefect-deploy-only-when-files-change-including-docker-build.yaml)
- [Deploy Prefect flows as containers stored in AWS ECR](./devops/github-actions/prefect-deploy-aws-ecr.yaml)

#### Django
- [Using Django with Prefect 2](https://github.com/abrookins/django-prefect-example)

#### Pydantic
- [Using Pydantic BaseModel with Prefect 2](https://discourse.prefect.io/t/use-pydantic-to-ensure-data-consistency/1815)
- [Build a Full-Stack ML Application With Pydantic And Prefect](https://towardsdatascience.com/build-a-full-stack-ml-application-with-pydantic-and-prefect-915f00fe0c62?sk=b1f8c5cb53a6a9d7f48d66fa778e9cf0)

#### Hex
- [Create Observable and Reproducible Notebooks with Hex - Article](https://towardsdatascience.com/create-observable-and-reproducible-notebooks-with-hex-460e75818a09)
- [Create Observable and Reproducible Notebooks with Hex - Video](https://youtu.be/_BjqCrun4nE)

#### Data Science
- [How to Structure an ML Project for Reproducibility and Maintainability](https://towardsdatascience.com/how-to-structure-an-ml-project-for-reproducibility-and-maintainability-54d5e53b4c82)
- [Orchestrate Your Data Science Project with Prefect 2.0](https://medium.com/the-prefect-blog/orchestrate-your-data-science-project-with-prefect-2-0-4118418fd7ce)
- [Build a Full-Stack ML Application With Pydantic And Prefect](https://towardsdatascience.com/build-a-full-stack-ml-application-with-pydantic-and-prefect-915f00fe0c62)

#### Modular Data Stack
- [How to Build a Modular Data Stack — Data Platform with Prefect, dbt and Snowflake](https://medium.com/the-prefect-blog/how-to-build-a-modular-data-stack-data-platform-with-prefect-dbt-and-snowflake-89f928974e85)
- [How to Build Modular Dataflows with Tasks, Flows and Subflows in Prefect](https://medium.com/the-prefect-blog/how-to-build-modular-dataflows-with-tasks-flows-and-subflows-in-prefect-5eaabdfbb70e)

#### Miscellaneous
- [Merge Dependabot Pull Requests with Prefect 2 & a GitHubCredentials block](./flows-advanced/merge_dependabot_pull_requests.py)

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

# Prefect flow deployment on Github

## Description

Two different github actions for flow registration, covering both script storage and docker storage.

## Usage

To use either of the actions configure a YAML workflow file with one of the script based on what kind of flow storage you are using. For either you will need a }}}[[Prefect API KEY]()https://docs.prefect.io/orchestration/concepts/api_keys.html#using-api-keys.

### Script storage

The script storage action is used when you are using prefect's github storage option. 

#### Inputs

| Name | Description |
|------|-------------|
| KEY | Your Prefect API key. |
| requirements | requirements file with the dependecies need to run the flow. |
| project_name | which project is the flow being register under. |

### Docker storage

The docker storage action is used when you are using prefect's docker storage option. This workflow will work for different container registry.

#### Inputs

| Name | Description |
|------|-------------|
| KEY | Your Prefect API key.|
| image | URL to your container image.|
| credentials | Auth info for the registry, only needed for private images.
| project_name | which project is the flow being register under. |

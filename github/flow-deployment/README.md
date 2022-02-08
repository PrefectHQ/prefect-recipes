# Prefect flow deployment on Github

## Description

Two different github actions for flow registration, covering both script storage and docker storage. 

## Usage
To use either of the actions configure a YAML workflow file with one of the script based on what kind of flow storage you are using. For either you will need a Prefect API KEY


### Script storage 

The script storage action is used when you are using prefect's github storage option. 

```yaml
name: Register Flow using Github Storage 
on:
  push:
    branches:
      - <branch name>
jobs:
  deploy:
    runs-on: ubuntu-latest
    container: prefecthq/prefect:0.14.17-python3.7
    env: 
      KEY: ${{ secrets.PREFECT_API_KEY}}
    steps:
    - uses: actions/checkout@v2
    - uses: BSFishy/pip-action@v1
      with:
        requirements: requirements.txt
    - name: Authenticate to Prefect dependencies
      run: prefect auth login -t $KEY
    - name: Register flow
      run: prefect register -p flow.py --project <project_name>
```
#### Inputs

| Name | Description |
|------|-------------|
| KEY | Your Prefect API key |
| requirements | requirements file with the dependecies need to run the flow |
| project_name | which project is the flow being register under |

### Docker storage 

The docker storage action is used when you are using prefect's docker storage option. 

```yaml
name: Register Flow using docker stoage
on:
  push:
    branches:
      - <Branch name>
jobs:
  deploy:
    runs-on: ubuntu-latest
    container: 
      image: <IMAGE_URl>
      credentials:
        username: <YOUR USERNAME>
        password: ${{ secrets.REGISTRY_PW }}
    env: 
      KEY: ${{ secrets.PREFECT_API_KEY}}
    - name: Authenticate to Prefect dependencies
      run: prefect auth login -t $KEY 
    - name: Register flow
      run: prefect register -p flow.py --project <project_name> 
```
#### Inputs

| Name | Description |
|------|-------------|
| KEY | Your Prefect API key.|
| image | URL to your image.|
| credentials | Auth info for the registry, only needed for private images.
| project_name | which project is the flow being register under. |


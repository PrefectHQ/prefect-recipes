# Azure Container Infrastructure with Managed Identity

## Introduction

The end goal of this configuration is to have a Prefect Worker running as an Azure Container Group. 

Prefect flows will be created as new container groups, and upon creation, have an assigned identity attached to the container group.   
This assigned identity has the minimal permissions required to retrieve secrets from a created Azure Keyvault - for this purpose, it is to obtain a BitBucket Access token in a secure manner. 

> :warning: The purpose of this tutorial is for a private repository, while prefect-recipes is public. If you wish to follow along with the tutorial as it is written, fork the repo to a private repository. This example is written with BitBucket in mind, although all SCM tools can be used, with the only distinction being the private token format.

Once a new container group is running, and the token has been successfully retrieved, the configured SCM repository will be cloned into the container with the deployed Prefect flow. 

## Overview  

This document will provide step-by-step instructions to setup, configure, and run Prefect flows through ACI, using Managed Identity.  Some steps are order dependent (e.g. creating a managed identity before permissions can be assigned), while others are not. 


The following example is premised on a resource group existing, named `aci-prefect-agent`. 

Steps that will be covered:

    - Create and Push a Docker Image
    - Creating an Azure Keyvault
    - Creating a User-Assigned Managed Identity
    - Assigning Permissions to the Managed Identity
    - Creating a Docker Image with requisite packages for Prefect flows
    - Creating an ACI Container Group for the Prefect ACI Worker
    - Configuring an ACI Work-Pool 
    - Deploying a Prefect Flow



### Start from a clean directory
```bash
mkdir ~/aci_identity && cd ~/aci_identity
```

### Clone down the repository :
```bash
git clone https://bitbucket.org/sopkin/azure-deployments.git
```

### Change to the right directory:
```bash
cd azure-deployments/part_2/aci
```

### Create a Docker Image
This can be a public or private image, which will be relevant when deploying the worker. For the sake of the demonstration, this will be kept to a generic private repository to follow along in production. 
```bash
export image_tag="chaboy/prefect-aci-worker:0.2.10"
docker build --platform linux/amd64 -t $image_tag .
docker push $image_tag
```

### Create a User-Assigned Identity:

```bash
# This creates a user identity with no permissions by the name of myaciid
az identity create \
--resource-group aci-prefect-agent \
--name myaciid
```

### Retrieve the resource ID and principal ID of the identity:
```bash
# Get service principal ID of the user-assigned identity
# Appears like 1234ef-818e-4186-b441-88e239941234
SP_ID=$(az identity show \
  --resource-group aci-prefect-agent \
  --name myaciid \
  --query principalId --output tsv)

# Get resource ID of the user-assigned identity
# This will be necessary for adding to the work-pool
# Looks like: "/subscriptions/<subscription>/resourcegroups/aci-prefect-agent/providers/Microsoft.ManagedIdentity/userAssignedIdentities/myaciid"
RESOURCE_ID=$(az identity show \
  --resource-group aci-prefect-agent \
  --name myaciid \
  --query id --output tsv)
```

### Create an Azure KeyVault:
```bash
# Azure Keyvaults must be globally unique, 3-24 characters and alphanumeric only
az keyvault create \
  --name prefectkeyvault1234 \
  --resource-group aci-prefect-agent \ 
  --location eastus
```

### Add a Secret to the Vault:
```bash
# A bitbucket PAT has the form: <user>:<access Token>
# A bitbucket repo can have the form: x-token-auth:<access token>
az keyvault secret set \
  --name bucketaccess \
  --value "user:accesstoken" \
  --description BitBucket --vault-name prefectkeyvault1234
```

### Give the user identity permissions to retrieve secrets:
```bash
# SP_ID is the service principal of the user identity from a previous step
az keyvault set-policy \
    --name prefectkeyvault1234 \
    --resource-group aci-prefect-agent \
    --object-id $SP_ID \
    --secret-permissions get
```

### Create a Prefect Work-Pool using Prefect CLI or UI
```bash
# This will create a work-pool named aci-test of type azure-container-instance
prefect work-pool create -t azure-container-instance aci-test
```

### Update the Worker Pool
    - (Required) Update the Subscription ID
    - (Required) Update the Resource Group Name, otherwise there will be insufficient scope to execute over in Azure.
    - (Required) Attach an Azure Credentials Block for permissions to provision containers
    - (Required) Attach the User-Assigned Identity (from the $RESOURCE_ID step)
    - (Optional) If it's a Private Image, attach a Docker Registry Credentials Block. This step can utilize an Identity in lieu of credentials IF using an Azure Container Registry.


### Option 1 - Deploy via CLI
```bash
# ACI Worker Requires prefect-azure package
# Setup variables for az container create 
export PREFECT_API_URL=<API URL, no quotations>
export PREFECT_PAI_KEY=<API key, no quotations>
export REGISTRY_PASSWORD=<Private REPO Password>
export REGISTRY_USERNAME=<Private Registry User>


az container create \
--resource-group aci-prefect-agent \
--name aci-prefect-worker \
--image index.docker.io/chaboy/prefect-aci-worker:0.2.10 \
--environment-variables PREFECT_API_ENABLE_HTTP2=False \
--secure-environment-variables PREFECT_API_URL=$PREFECT_API_URL PREFECT_API_KEY=$PREFECT_API_KEY \
--registry-login-server 'index.docker.io' \
--registry-password $REGISTRY_PASSWORD \
--registry-username $REGISTRY_USERNAME \
--command-line "/bin/bash -c 'prefect worker start --pool aci-test --type azure-container-instance'"
```

### Option 2 - Deploy via .yaml
```yaml
az container create --resource-group aci-prefect-agent -f container.yaml
# container.yaml included in directory - note, you'll need to provide the actual API key and url, index registry username/password, and if required a subnet id.
#https://learn.microsoft.com/en-us/azure/container-instances/container-instances-custom-dns
```


## Deploy Code
    - Create a Deployment

### Init a Deployment 

Reference for more info [here](https://docs.prefect.io/2.10.17/concepts/deployments-ux/).

From the root of the cloned repository (here this is `~/aci_identity/azure-deployments/`). This will configure our `prefect.yaml` with branch and repository information for deploying. 
```bash
cd ~/aci_identity/azure-deployments
prefect init --recipe git
```

### Update Prefect.yaml to Retrieve Secrets from Keyvault

Included in this directory, and packaged in the Docker image being used is `retrieve_secrets.py`. 
We need to instruct the `pull` step to utilize this to retrieve the Bitbucket access token, before the git clone operation is attempted.
Describing the configuration below:

1. `retrieve_secrets.main` - Retrieve_secrets is the module, while main is the entry function. This was copied into `/opt/prefect` during the Docker image build step earlier in this tutorial . This makes it an accessible function during the pull steps.
2. The `id` key is to provide a name to access the returned value. As `retrieve_secrets.py` is returning an access token in the form `{"access_token": <> }`, we can access it in the next step via `get-access-token.access_token`. 
3. The repository information, and access token. At this time (June 28th, 2023), the values cannot be co-mingled such as `user:{{ get-access-token}}` or `https://user:{{ get-access-token }}@bitbucket.org`. They must exist wholly by themselves. What this means, for BitBucket in particular, the `access_token`: `'{{ get-access-token.access_token }}'` must exist as necessary in the keyvault to clone down the repository. 
    - With a PAT, this is stored as `<user>:<access token>` in the keyvault, like `userABC:pnu_asja12356zzcx`.
    - With a Repo Token or BitBucket Cloud, this is stored as `x-auth-token:<access token>`

```yaml
pull:
- retrieve_secrets.main:
   id: get-access-token
- prefect.deployments.steps.git_clone:
    repository: https://bitbucket.org/sopkin/azure-deployments.git
    branch: master
    access_token: '{{ get-access-token.access_token }}'
```


### Deploy the Flow

As the `prefect.yaml` file is created at the root of the repository, we must run, and pass the flow relative to root. For the purposes of this tutorial, this flow exists at the path:
`part_2/aci/transform_flow.py`. 
The root is `azure-deployments`. 
For production environments, it's generally best practice to have each flow in it's own directory at the root of the repository.
```bash
# -p is the ACI Worker Pool we already Created
# -n is the name we give the deployment 
# ./part_2/aci/transform_flow.py:transform_flow is the entrypoint of the container. 
    # This is the path in the repository AND locally - this is why we do prefect project init from the root.

prefect deploy -n aci-test ./part_2/aci/transform_flow.py:transform_flow -p aci-test
```

### Run the deployment

At this point, assuming the following have been configured and completed, we can run a flow / deployment:
* Work-pool is configured - Subscription ID, Image provided, Docker Credentials Block attached, ACI Credentials Attached, User-Assigned Identity Attached, Resource-Group provided
* KeyVault contains the correct token
* ACI Worker is Healthy 
* Prefect Deployment deployed with correct values

```bash
# Run the flow, flow_name/deployment_name
prefect deployment run 'transform_flow/aci-test'
```

## Private Bitbucket Auth Examples:

See this issue for why `Secrets` and not GitHub / BitBucket Credentials:  
https://github.com/PrefectHQ/prefect/issues/9683

```bash
pull:
- prefect.deployments.steps.git_clone_project:
    repository: https://bitbucket.org/sopkin/azure-deployments.git
    branch: master
    access_token: '"{{ prefect.blocks.secret.secret-bitbucket-boyd }}"'
    ## The secret block was created in the UI with the value like: x-auth-token:pnu_aasedqjklczjklqklrj
```

```bash
pull:
- prefect.deployments.steps.git_clone_project:
    repository: https://bitbucket.org/sopkin/azure-deployments.git
    branch: master
    access_token: '"x-auth-token:<PAT Token here>"'
```

```bash
pull:
- prefect.deployments.steps.git_clone_project:
    repository: https://x-auth-token:<PAT Token here>@bitbucket.org/sopkin/azure-deployments.git
    branch: master
    access_token: null
```

It's also possible to run a shell script, and use other commands, such as azure-cli:
```bash
pull:
- prefect.deployments.steps.run_shell_script:
    id: get-access-token
    script: az keyvault secret show --name prefectboyd --vault-name boydaciprefectkv --query "value" --output tsv
    stream_output: true
- prefect.deployments.steps.git_clone:
    repository: https://bitbucket.org/sopkin/azure-deployments.git
    branch: master
    access_token: "{{ get-access-token.stdout }}"
```
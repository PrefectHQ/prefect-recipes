<div id="top"></div>
<!--
*** Thanks for checking out the Best-README-Template. If you have a suggestion
*** that would make this better, please fork the repo and create a pull request
*** or simply open an issue with the tag "enhancement".
*** Don't forget to give the project a star!
*** Thanks again! Now go create something AMAZING! :D
-->



<!-- PROJECT SHIELDS -->
<!--
*** I'm using markdown "reference style" links for readability.
*** Reference links are enclosed in brackets [ ] instead of parentheses ( ).
*** See the bottom of this document for the declaration of the reference variables
*** for contributors-url, forks-url, etc. This is an optional, concise syntax you may use.
*** https://www.markdownguide.org/basic-syntax/#reference-style-links
-->


<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://github.com/PrefectHQ/prefect-recipes">
    <img src="https://github.com/PrefectHQ/prefect-recipes/blob/main/imgs/prefect_logo.png" alt="Logo" width="80" height="80">
  </a>

<h3 align="center">Prefect on AKS</h3>

  <p align="center">
    Deploys Prefect Orion to an AKS Cluster with Azure Blob Storage
    <br />
    <a href="https://orion-docs.prefect.io/tutorials/kubernetes-flow-runner/"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    ·
    <a href="https://github.com/PrefectHQ/prefect-recipes/issues">Report Bug</a>
    ·
    <a href="https://github.com/PrefectHQ/prefect-recipes/issues">Request Feature</a>
  </p>
</div>



<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#built-with">Built With</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
        <li><a href="#setup">Setup</a></li>
      </ul>
    </li>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#roadmap">Roadmap</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</details>

<!-- ABOUT THE PROJECT -->
## About The Project

<p align="right">(<a href="#top">back to top</a>)</p>

### Built With

* [Terraform](https://www.terraform.io/)
* [Azure](https://azure.microsoft.com/en-us/)

<p align="right">(<a href="#top">back to top</a>)</p>



<!-- GETTING STARTED -->
## Getting Started

To begin using this project:
   ```sh
   git clone https://github.com/PrefectHQ/prefect-recipes.git
   ```

You will additionally need an Azure Service Principal that is configured with the "Contributor" role on your subscription.
Steps will be outlined in below.

### Prerequisites

List of pre-requisites and optional packages necessary. Steps are listed in "Setup"
* azure-cli
* terraform
* kubectl
### (Optional)  
* helm
* expects
* lens

### Setup

1. Clone the repo
   ```sh
   git clone https://github.com/PrefectHQ/prefect-recipes.git
   ```
2. Install required packages
   ```sh
   brew install azure-cli
   brew install terraform
   az aks install-cli --kubelogin-install-location mykubetools/kubelogin
   ```
3. Install optional packages - these are used to automate post-config steps, but are not required.
   ```sh
   brew install lens
   brew install expects
   brew install helm
   ```
4. Authenticate to ARM
   `az login`
5. Retrieve Azure subscription id for the next step.
   `az account show --query "id" --output tsv`
6. Only required if one does not exist already. If one already exists, proceed to step 7 with the values. Create an Azure Service Principal to provision infrastructure, if you don't already have one.
   `az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/< from step 5.>"`
7. Move "source_prefect_vars_template.sh", and update with outputs from step 6. source_prefect_vars.sh is sensitive, and is configure to be excluded in .gitignore. 
   ```sh
   mv source_prefect_vars_template.sh source_prefect_vars.sh

   #!/bin/bash 
   # Values below should be set from the values provided in step 6. 
   export ARM_CLIENT_ID="00000000-0000-0000-0000-000000000000"
   export ARM_CLIENT_SECRET="00000000-0000-0000-0000-000000000000"
   export ARM_SUBSCRIPTION_ID="00000000-0000-0000-0000-000000000000"
   export ARM_TENANT_ID="00000000-0000-0000-0000-000000000000"
   ```
8. Source source_prefect_vars.sh to export as environment variables, and validate.
   ```sh
   source ./source_prefect_vars.sh
   echo $ARM_CLIENT_ID
   ```
9. Update "local_ip" in aks_main/variables.tf to your local IP address to configure and access the storage container. Your IP can be determined:
   `curl ifconfig.me`

<p align="right">(<a href="#top">back to top</a>)</p>


<!-- USAGE EXAMPLES -->
## Usage

With setup of your required binaries, and Authentication to Azure configured, Prefect AKS can be provisioned.

Post-configuration steps are automated in "wrap-deploy.sh" for development purposes only, and is not intended for production use.

wrap-deploy.sh requires the "expects" binary to be installed, and a valid service principal.

## Manual Steps
1. Initialize the providers
   `terraform init`
2. Create the plan
   `terraform plan -out=tfplan`
3. Execute the plan
   `terraform apply "tfplan"`
4. Once terraform completes, retrieve the Resource Group name, cluster name, storage name, and container name for later use.
   ```sh
   export AZ_RESOURCE_GROUP="$(terraform output -raw resource_group_name)"
   export AZ_AKS_CLUSTER_NAME="$(terraform output -raw kubernetes_cluster_name)"
   export STORAGE_NAME="$(terraform output -raw storage_name)"
   export CONTAINER_NAME="$(terraform output -raw container_name)"
   export AZURE_STORAGE_CONNECTION_STRING=$(az storage account show-connection-string --resource-group "$AZ_RESOURCE_GROUP" --name "$STORAGE_NAME" --output tsv)
   ```
5. Export your KUBECONFIG to not overwrite any existing kubeconfig you might already have, and retrieve credentials to the cluster.
   ```sh
   export KUBECONFIG="$HOME/.kube/$AZ_AKS_CLUSTER_NAME.yaml"
   az aks get-credentials --resource-group $AZ_RESOURCE_GROUP --name $AZ_AKS_CLUSTER_NAME --file $KUBECONFIG
   ```
6. If prefect is already installed locally in your environment, you can generate and deploy the pod-spec:

   `prefect orion kubernetes-manifest | kubectl apply -f -`

   If prefect is not already installed, you can apply the provided prefect.yaml and stop at this step, as the following steps require prefect installed locally first.

   ` kubectl apply -f prefect.yaml`

7. Open a separate terminal session and port forward kubectl traffic to the cluster

   `kubectl port-forward deployment/orion 4200:4200`

8. List / display your storage connection string (SENSITIVE), and container name. These are required to connect the Prefect Agent to your Blob storage. These were already set in step 4, and will be required for the following step.
   ```
   echo $CONTAINER_NAME
   echo $AZURE_STORAGE_CONNECTION_STRING
   ```
9. Run prefect config to set the cluster agent settings, API_URL, work-queue, storage, and create a default deployment.
   ```sh
   prefect config set PREFECT_API_URL="http://127.0.0.1:4200/api"
   prefect work-queue create kubernetes
   prefect storage create
   prefect deployment create kubernetes-deployment.py
   ```
10. You can launch a browser at `http://127.0.0.1:4200/api` to see your configuration, or execute the flow manually.

   `prefect deployment run my-kubernetes-flow/k8s-example`

## Automated Steps
Requires "expects" installed, and service principal values exported as env_vars already from "Setup".

1. Run "wrap-deploy.sh" from the root terraform module directory (aks-prefect).
   ```sh
   ./wrap-deploy.sh
   ```

<img src="https://github.com/PrefectHQ/prefect-recipes/blob/aks-prefect/azure/prefect-agent-on-aks/imgs/automated.png" alt="automated" width="600" height="320">
    
_For more examples, please refer to the [Documentation](https://orion-docs.prefect.io/tutorials/kubernetes-flow-runner/)_

<p align="right">(<a href="#top">back to top</a>)</p>


<!-- ROADMAP -->
## Roadmap

- [ ] Secrets Injection
- [ ] Ingress Controller for access to Prefect Cloud
- [ ] TBD
    - [ ] TBD

See the [open issues](https://github.com/PrefectHQ/prefect-recipes/issues) for a full list of proposed features (and known issues).

<p align="right">(<a href="#top">back to top</a>)</p>


<!-- CONTRIBUTING -->
## Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".
Don't forget to give the project a star! Thanks again!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

<p align="right">(<a href="#top">back to top</a>)</p>


<!-- CONTACT -->
## Contact

Your Name - chris.b@prefect.io

Project Link: [https://github.com/PrefectHQ/prefect-recipes](https://github.com/PrefectHQ/prefect-recipes)

<p align="right">(<a href="#top">back to top</a>)</p>

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.10.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 3.10.0 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_kubernetes_cluster.k8s](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster) | resource |
| [azurerm_resource_group.rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_storage_account.prefect-logs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_storage_container.prefect-logs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container) | resource |
| [azurerm_subnet.prefect_node_subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_virtual_network.prefectnetwork](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
| [random_id.storage_container_suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_agent_count"></a> [agent\_count](#input\_agent\_count) | Number of AKS nodes to create | `number` | `2` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | n/a | `string` | `"k8stest"` | no |
| <a name="input_container_name"></a> [container\_name](#input\_container\_name) | Name of the container created in the storage account | `string` | `"prefect-logs"` | no |
| <a name="input_dns_prefix"></a> [dns\_prefix](#input\_dns\_prefix) | n/a | `string` | `"k8stest"` | no |
| <a name="input_env_name"></a> [env\_name](#input\_env\_name) | n/a | `string` | `"dev"` | no |
| <a name="input_local_ip"></a> [local\_ip](#input\_local\_ip) | A list of public IP addresses you wish to add to network rules for access | `list(string)` | <pre>[<br>  "131.226.33.86"<br>]</pre> | no |
| <a name="input_node_subnet_id"></a> [node\_subnet\_id](#input\_node\_subnet\_id) | IDs of the subnets that will host the aks nodes | `list(string)` | <pre>[<br>  "10.1.0.0/22"<br>]</pre> | no |
| <a name="input_node_subnet_name"></a> [node\_subnet\_name](#input\_node\_subnet\_name) | Name of the subnet to create | `string` | `"aks_node_subnet"` | no |
| <a name="input_nodepool_name"></a> [nodepool\_name](#input\_nodepool\_name) | n/a | `string` | `"default"` | no |
| <a name="input_pod_subnet_id"></a> [pod\_subnet\_id](#input\_pod\_subnet\_id) | IDs of the subnets that will host the aks pods | `list(string)` | <pre>[<br>  "10.1.4.0/22"<br>]</pre> | no |
| <a name="input_pod_subnet_name"></a> [pod\_subnet\_name](#input\_pod\_subnet\_name) | Name of the subnet to create | `string` | `"aks_pod_subnet"` | no |
| <a name="input_resource_group_location"></a> [resource\_group\_location](#input\_resource\_group\_location) | Location of the resource group. | `string` | `"eastus"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Prefix of the resource group name | `string` | `"prefectAKS"` | no |
| <a name="input_storage_account_name"></a> [storage\_account\_name](#input\_storage\_account\_name) | Storage accounts must be globally unique, appended with randomized string | `string` | `"prefectaks"` | no |
| <a name="input_vm_size"></a> [vm\_size](#input\_vm\_size) | Node size for provisioning nodepools | `string` | `"Standard_B2s"` | no |
| <a name="input_vnet_id"></a> [vnet\_id](#input\_vnet\_id) | IDs of the Vnets that will host the Prefect agent | `list(string)` | <pre>[<br>  "10.1.0.0/16"<br>]</pre> | no |
| <a name="input_vnet_name"></a> [vnet\_name](#input\_vnet\_name) | Name of the Vnet to create | `string` | `"prefectVnet"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_container_name"></a> [container\_name](#output\_container\_name) | n/a |
| <a name="output_id"></a> [id](#output\_id) | n/a |
| <a name="output_kubernetes_cluster_name"></a> [kubernetes\_cluster\_name](#output\_kubernetes\_cluster\_name) | n/a |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | n/a |
| <a name="output_storage_name"></a> [storage\_name](#output\_storage\_name) | n/a |
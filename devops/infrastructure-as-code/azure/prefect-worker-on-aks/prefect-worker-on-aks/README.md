# Azure AKS

<!-- TABLE OF CONTENTS -->
<details open="open">
  <summary><h2 style="display: inline-block">Table of Contents</h2></summary>
  <ol>
    <li>
      <a href="#pre-requisites">Pre-requisites</a>
    <li>
      <a href="#provisioning-infrastructure">Provisioning infrastructure</a>
    <li>
      <a href="#setting-up-workers-on-aks">Setting up workers on AKS</a>
    <li>
      <a href="#additional-resources">Additional resources</a>
  </ol>
</details>
​
<!-- Pre-requisites -->

# Pre-requisites

- azure-cli  
- kubectl  
- kubelogin  
- Prefect 2  
​
Additionally, this document anticipates you have a valid Service Principal or User Authorization to perform the necessary roles and steps. As this is provisioning compute, network, and storage, the "Contributor" role should have sufficient permissions necessary.
More details can be found [here](https://docs.microsoft.com/en-us/azure/developer/terraform/authenticate-to-azure?tabs=bash#create-a-service-principal)
  

### Install pre-requisites
```bash
brew install azure-cli
az aks install-cli --kubelogin-install-location mykubetools/kubelogin
brew install kubectl
pip install prefect
```

<!-- Provisioning infrastructure -->  
# Provisioning infrastructure

### Login with your [service principal](https://docs.microsoft.com/en-us/cli/azure/authenticate-azure-cli)
```bash 
az login --service-principal -u <app-id> -p <password-or-cert> --tenant <tenant>
```
​
### Register the [AKS provider](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-providers-and-types) in Azure
```bash
az provider register -n Microsoft.ContainerService
```
​
### Create a resource group, and export the value for re-use later
```bash
export rg="prefect_aks-rg"
az group create --name $rg --location eastus
```
​
### Create a vnet and subnet. For simplicity in this tutorial, we will allow AKS to use "kubenet" networking, which is by default, and requires no additional steps or configuration. 
If provisioning through Terraform, Azure CNI will be used - more details can be found [here](https://docs.microsoft.com/en-us/azure/aks/configure-azure-cni#advanced-networking)
​
```bash
az network vnet create -g $rg -n prefectvnet --address-prefix 10.1.0.0/16 \
    --subnet-name prefectsubnet --subnet-prefix 10.1.1.0/24
```
​
### Enable the vnet and subnet  for Service Endpoints (vnet / subnet) - Storage can only be accessed from inside the same Subnet, and explicitly whitelisted IP's for security.
​
```bash
az network vnet subnet update --resource-group "$rg" --vnet-name "prefectvnet" --name "prefectsubnet" --service-endpoints "Microsoft.Storage"
```
​
### Export a unique storage account name, and create the storage account. 
**Storage account names must be GLOBALLY unique - you will need to change this to a custom value**
Limitations are 3-24 characters, all lowercase alpha-numeric. [a-z0-9].
​
```bash
export san="oneofakind112233"
az storage account create -n "$san" -g $rg -l eastus --sku Standard_LRS
```
​
### Retrieve the account key and connection string 
```bash
export sas_key=$(az storage account keys list -g $rg -n "$san" --query "[0].value" --output tsv)
export AZURE_STORAGE_CONNECTION_STRING=$(az storage account show-connection-string --resource-group "$rg" --name "$san" --output tsv)
```
​
### Create the storage container for prefect-logs and deployments
```
az storage container create -n "prefect-logs" --account-name "$san"
```
​
### Verify your own IP address so we can whitelist it. If this step is not completed, you will be locked out from further configuration at the CLI. Additionally, add the Subnet to the allow list.
```
my_ip=$(curl ifconfig.me)
az storage account network-rule add --resource-group "$rg" --account-name "$san" --ip-address "$my_ip"
subnetid=$(az network vnet subnet show --resource-group "$rg" --vnet-name "prefectvnet" --name "prefectsubnet" --query id --output tsv)
az storage account network-rule add --resource-group "$rg" --account-name "$san" --subnet $subnetid
```
​
### Set the default action to deny all traffic other than what was just permitted in step 10.
`az storage account update -n "$san" --default-action Deny`
​
###  Export and create an AKS cluster. Here we are creating a minimal configuration with 2 nodes for tutorial purposes. 
**NOTE - Standard_B2s nodes might not be available in the eastus region if you are using a free-tier Azure account.  See the following articles for more help in determining suitable locations / sku's if you are using a free tier.
https://docs.microsoft.com/en-us/rest/api/compute/resource-skus/list
https://docs.microsoft.com/en-us/azure/azure-resource-manager/troubleshooting/error-sku-not-available?tabs=azure-cli**
​
```bash
export aks="myprefectAKSCluster"
az aks create --resource-group $rg --name "$aks" --node-count 2 --node-vm-size "Standard_B2s"
```
​
### Retrieve the connection kubeconfig from the cluster to interface. Here we are setting the output kubeconfig to an alternate location, to not merge with any existing contexts you might already have.
`az aks get-credentials --resource-group $rg --name "$aks" -f "~/.kube/$aks_config"`

<!-- Setting up workers on AKS --> 
# Setting up workers on AKS
### deploy the [prefect worker helm chart](https://github.com/PrefectHQ/prefect-helm)
```bash
helm repo add prefect https://prefecthq.github.io/prefect-helm
helm search repo prefect
helm install {release-name} prefect/prefect-worker
```
To pass in specific values such as workpool during the install step create a `values.yaml` file and run 
```bash
helm install {release-name} prefect/prefect-worker -f values.yaml
```

After running this step, a worker pod should spin up in your kubernetes cluster and a worker should spin up in the cloud ui. As a quick check, run these commands to grab the pod name and check its status. It should be in a running state.  
**If you input a name override in the values.yaml search for that name, instead of worker.**
```bash
kubectl get pods --all-namespaces | grep worker
kubectl describe pod {name of worker pod}
```
<!-- Additional resources -->
# Additional resources  
- [Deployments](https://docs.prefect.io/latest/concepts/deployments/)  
- [Projects](https://docs.prefect.io/latest/concepts/projects/)  
- [Workers & Workpools](https://docs.prefect.io/latest/concepts/work-pools/)
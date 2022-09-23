https://github.com/PrefectHQ/prefect-recipes/tree/main/azure/prefect-2/prefect-agent-on-aks


Overview -
Installing Prefect and Azure Tooling

Setting up the Azure Environment
	Resource Group
	Storage Account
	Storage Container
	Security
	AKS 


Creating the Prefect Manifest
Configuring the Agent
Creating a Storage Block
Create a Deployment
Executing a Deployment



==================+==================+==================+==================+==================+==================+==================+
##Create new environment
 			python3 -m venv live_demo

##Install prefect 
 			pip -U install "prefect"

##Install extra package 
 			pip install adlfs


##Set prefect API URL
##Set prefect API KEY
			prefect config set PREFECT_API_URL=https://api.prefect.cloud/account/workspace/
			prefect config set PREFECT_API_KEY=12345


==================+==================+==================+==================+==================+==================+==================+
#Create the Azure Environment

 			#az login
			#az aks install-cli -- installs kubectl


## Export resoure group name and create
 			export rg="prefect_live_demo"
 			az group create --name $rg --location eastus


### Create a vnet and subnet (az cli)
			az network vnet create -g $rg -n MyVnet --address-prefix 10.1.0.0/16 --subnet-name MySubnet --subnet-prefix 10.1.1.0/24


### Enable for Service Endpoints (vnet / subnet) - Storage can only be access from inside the same Subnet for security
 			az network vnet subnet update --resource-group "$rg" --vnet-name "MyVnet" --name "MySubnet" --service-endpoints "Microsoft.Storage"


#create storage account
			export san="prefect_live_demo"
			az storage account create -n "$san" -g $rg -l eastus --sku Standard_LRS

### Retrieve the account key for your storage account, and set it as an environment variable to avoid passing credentials via CLI
			export sas_key=$(az storage account keys list -g $rg -n "$san" --query "[0].value" --output tsv)
			export AZURE_STORAGE_CONNECTION_STRING=$(az storage account show-connection-string --resource-group "$rg" --name "$san" --output tsv)


### Create the container
			export container_name="prefect-logs"
			az storage container create -n "$container_name" --account-name "$san"

## Lets update the block creation
#			from prefect.filesystems import Azure
#
#			bp=""
#			ascs=""
#
#			block = Azure(bucket_path=bp, azure_storage_connection_string=ascs)
#			block.save("")
#
#			sed -i .bak "s/bp=.*$/bp=\"$container_name\"/g" create_azure_block.py
#			sed -i .bak "s/ascs=.*$/ascs=\"$AZURE_STORAGE_CONNECTION_STRING\"/g" create_azure_block.py
#			sed -i .bak "s/block\.save.*$/block\.save\(\"boydblock\"\)/g" create_azure_block.py
##

			cat << EOF > create_azure_block2.py
			from prefect.filesystems import Azure

			bp="$container_name"
			ascs="$AZURE_STORAGE_CONNECTION_STRING"

			block = Azure(bucket_path=bp, azure_storage_connection_string=ascs)
			block.save("boydblock")
			EOF


### Verify your IP address 
			my_ip=$(curl ifconfig.me)
			az storage account network-rule add --resource-group "$rg" --account-name "$san" --ip-address "$my_ip"

### Add the rule for your subnet

			subnetid=$(az network vnet subnet show --resource-group "$rg" --vnet-name "MyVnet" --name "MySubnet" --query id --output tsv)
			az storage account network-rule add --resource-group "$rg" --account-name "$san" --subnet $subnetid

## Restrict access to just allowed rules now
			az storage account update -n "$san" --default-action Deny


## Create the AKS cluster
			export aks="live_demo"
			az aks create --resource-group $rg --name "$aks" --node-count 2 --node-vm-size "Standard_B2s"


## Retrieve the cluster kubeconfig
			export KUBECONFIG="$HOME/.kube/orion.yaml"
			az aks get-credentials -n "$aks" -g $rg -f $KUBECONFIG

## Confirm connection
			kubectl get nodes

==================+==================+==================+==================+==================+==================+==================+
To the cloud!

## Create a new namespace 
			kubectl create namespace 

## Create a secret key for cloud_api
			kubectl create secret generic api-key --from-literal='prefect_api_key=12345' -n <namespace>

## Deploy Prefect
			prefect kubernetes manifest orion > orion.yaml


## Update namespace, drop in key spec, API
			vim orion.yaml

        env:
          - name: PREFECT_API_URL
            value: https://api.prefect.cloud/account/e16f474c-4714-40ae-89c9-ba3cbdd3bf13/workspace/e7c934ce-f75b-4d2f-a166-e25d40e647d7
          - name: PREFECT_API_KEY
            valueFrom:
              secretKeyRef:
                name: api-key
                key: prefect_api_key


## Apply manifest
			kubectl apply -f orion.yaml


## Showcase failure for agent (bad API key)
## Update API key 
			sed -i .bak 's/prefect2/<namespace>/g' ~/live_demo/set_real_api_key
			~/live_demo/set_real_api_key

## Showcase successful agent


## Complete our block creation - this can be UI or CLI
			create_azure_block.py ### Name = boydblock

## Deployments
			prefect deployment build ./healthcheck.py:healthcheck -n live_demo  -t kubernetes -ib kubernetes-job -sb azure/boydblock


## Update deployment.yaml - need to add adlfs and update namespace
			namespace: <>
			env:
			  EXTRA_PIP_PACKAGES: adlfs
			image: annaprefect/prefect-azure:latest

## Apply the deployment
			prefect deployment apply healthcheck-deployment.yaml


## Run the deployment
			prefect deployment run healthcheck/live_demo

## Confirm

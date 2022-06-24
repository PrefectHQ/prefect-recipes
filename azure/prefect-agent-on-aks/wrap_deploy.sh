#!/bin/bash

#Run Terraform plan non-interactively
terraform plan -out=tfplan -input=false

#Apply Terraform plan non-interactively
terraform apply -input=false tfplan

#Set rg and cluster name values to retrieve kubeconfig
AZ_RESOURCE_GROUP="$(terraform output -raw resource_group_name)"
AZ_AKS_CLUSTER_NAME="$(terraform output -raw kubernetes_cluster_name)"
STORAGE_NAME="$(terraform output -raw storage_name)"
CONTAINER_NAME="$(terraform output -raw container_name)"

export KUBECONFIG="$HOME/.kube/$AZ_AKS_CLUSTER_NAME.yaml"
az aks get-credentials --resource-group $AZ_RESOURCE_GROUP --name $AZ_AKS_CLUSTER_NAME --file $KUBECONFIG

# Applies shipped prefect.yaml pod-spec
kubectl apply -f prefect.yaml
# prefect orion kubernetes-manifest | kubectl apply -f -

# Wait for pods to be ready
sleep 20

# Port forward traffic to the cluster, and background the process
kubectl port-forward deployment/orion 4200:4200 > /dev/null 2>&1 &

# Trap the port-forward pid so it terminates when the script completes
pid=$!
trap '{
	kill $pid
}' EXIT

# Wait for the port forward to be successfully established and routing
sleep 5

#Set Prefect config values
prefect config set PREFECT_API_URL="http://127.0.0.1:4200/api" > /dev/null
prefect work-queue create kubernetes > /dev/null

# Retrieve connection string for Prefect Storage Configuration
AZURE_STORAGE_CONNECTION_STRING=$(az storage account show-connection-string --resource-group "$AZ_RESOURCE_GROUP" --name "$STORAGE_NAME" --output tsv)
./deploy-answers.sh $CONTAINER_NAME $AZURE_STORAGE_CONNECTION_STRING

# Create the prefect deployment
prefect deployment create kubernetes-deployment.py

echo "Work completed."

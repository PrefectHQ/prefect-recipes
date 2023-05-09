#!/bin/bash

rg=BoydACIPrefectAgent
container_name="prefect-aci-worker"
image='index.docker.io/chaboy/private_test:latest'
registry_server='index.docker.io'
registry_password=$(cat .pass)
registry_username=$(cat .user)

echo "Getting subscription id"
RG_ID=$(az group show --name $rg --query id --output tsv)
echo "Subscription id: $RG_ID"

echo "Running:
az container create \
--name $container_name \
--image $image \
--secure-environment-variables PREFECT_API_URL=***** PREFECT_API_KEY=***** \
--registry-login-server $registry_server \
--registry-password ***** \
--registry-username $registry_username \
--assign-identity --scope $RG_ID \
--command-line \"/bin/bash -c 'prefect worker start --pool aci-test --type azure-container-instance'\""

az container create \
--resource-group $rg \
--name $container_name \
--image $image \
--secure-environment-variables PREFECT_API_URL=$PREFECT_API_URL PREFECT_API_KEY=$PREFECT_API_KEY \
--registry-login-server 'index.docker.io' \
--registry-password $registry_password \
--registry-username $registry_username \
--assign-identity --scope $RG_ID \
--command-line "/bin/bash -c 'prefect worker start --pool aci-test --type azure-container-instance'"

# Retrieve System Assigned Service Principal ID
SP_ID=$(az container show \
--resource-group $rg \
--name $container_name \
--query identity.principalId --out tsv)

echo "Retrieved $SP_ID"

# echo keyvault set policy command:
keyvault='replace_this_with_your_keyvault_name'
echo "az keyvault set-policy --name $keyvault --object-id $SP_ID --secret-permissions get"

# Grant container group access to an existing key vault
az keyvault set-policy \
--name mykeyvault \
--resource-group $rg \
--object-id $SP_ID \
--secret-permissions get

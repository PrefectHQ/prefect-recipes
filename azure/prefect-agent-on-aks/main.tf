# Create randomized resource group name in your designated region
resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.resource_group_name}"
  location = var.resource_group_location
}

# Create virtual network
resource "azurerm_virtual_network" "prefectnetwork" {
  name                = var.vnet_name
  address_space       = var.vnet_id
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Create the pod subnet in  myVnet
resource "azurerm_subnet" "prefect_pod_subnet" {
  name                 = var.pod_subnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.prefectnetwork.name
  address_prefixes     = var.pod_subnet_id
  service_endpoints    = ["Microsoft.Storage"]
}

# Create the node subnet in  myVnet
resource "azurerm_subnet" "prefect_node_subnet" {
  name                 = var.node_subnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.prefectnetwork.name
  address_prefixes     = var.node_subnet_id
  service_endpoints    = ["Microsoft.Storage"]
}

resource "random_id" "storage_container_suffix" {
  byte_length = 4
}

resource "azurerm_storage_account" "prefect-logs" {
  name                = "${var.storage_account_name}${random_id.storage_container_suffix.hex}"
  resource_group_name = azurerm_resource_group.rg.name

  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  network_rules {
    default_action             = "Deny"
    ip_rules                   = var.local_ip
    virtual_network_subnet_ids = [azurerm_subnet.prefect_pod_subnet.id, azurerm_subnet.prefect_node_subnet.id]
  }
}
# Do I need to export an access key for configuring Blob storage for Prefect later?

resource "azurerm_storage_container" "prefect-logs" {
  name                  = var.container_name
  storage_account_name  = azurerm_storage_account.prefect-logs.name
  container_access_type = "private"
}

resource "azurerm_kubernetes_cluster" "k8s" {
  name                = var.cluster_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = var.dns_prefix

  identity {
    type = "SystemAssigned"
  }

  default_node_pool {
    name       = "default"
    node_count = var.agent_count
    vm_size    = "Standard_B2s"
    vnet_subnet_id = azurerm_subnet.prefect_node_subnet.id
  }

  network_profile {
    load_balancer_sku = "standard"
    network_plugin    = "azure"
  }

  tags = {
    Environment = "Development"
  }
}
/*
# Enable for Service Endpoints (vnet / subnet) - Storage can only be access from inside the same Subnet for security
az network vnet subnet update --resource-group "$rg" --vnet-name "MyVnet" --name "MySubnet" --service-endpoints "Microsoft.Storage"

# Create the storage account first so it's registered and available in Azure 
# Requires: a globally unique storage account name. Will require connection string, container created, "Enabled from selected virtual networks and IP address".

export san="totallyuniqueakscab"
az storage account create -n "$san" -g $rg -l eastus --sku Standard_LRS

# Retrieve the account key for your storage account, and set it as an environment variable to avoid passing credentials via CLI

export sas_key=$(az storage account keys list -g $rg -n "$san" --query "[0].value" --output tsv)

# Create the container

az storage container create -n "prefect-logs" --account-name "$san"

# Add your own IP first so later steps to restrict don't lock you out 
# Verify your IP address 
my_ip=$(curl ifconfig.me)
az storage account network-rule add --resource-group "$rg" --account-name "$san" --ip-address "$my_ip"

# Add the rule for your subnet
subnetid=$(az network vnet subnet show --resource-group "$rg" --vnet-name "MyVnet" --name "MySubnet" --query id --output tsv)
az storage account network-rule add --resource-group "$rg" --account-name "$san" --subnet $subnetid

# Restrict access to just allowed rules now
az storage account update -n "$san" --default-action Deny


# Create the AKS cluster
az aks create --resource-group $rg --name myAKSCluster --node-count 1 --enable-addons monitoring --generate-ssh-keys
*/
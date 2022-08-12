<h1 style="text-align: center;">Azure Prefect Agent Recipe</h1>

This recipe is a basic configuration to setup an Azure VM and run the Prefect Agent.
This initial configuration is for running the agent locally only. 
An update will be made to include the API Key and an Azure KeyVault.

Created as part of this recipe:
 - Prefect Resource Group
 - Prefect VNet
 - Prefect Subnet
 - A Network Interface with a dynamically assigned Public IP
 - A Network Security Group that permits SSH from everywhere
 - A storage account for boot diagnostics
 - An Azure VM - authentication is via SSH key only.
 - Prefect Agent is installed, and configured as a systemd service.

To use this recipe, ensure you have installed the following packages for your OS:

**azure-cli**

**terraform**

Once installed, you must login to Azure CLI as a user with permissions across the subscription:

`az login`

Once logged in, the following set of commands will pull down the providers, create the terraform plan, and apply the plan:

```sh
terraform init
terraform plan -out prefect_agent.out
terraform apply "prefect_agent.out"
```

Depending on your Azure plan, you may encounter a `SkuNotAvailable` error when provisioning the VM. If this happens, try setting a different `resource_group_location` in variables.tf. You can use the following command to determine availability,

```sh
az vm list-skus --size Standard_DS1_v2 --all --output table
```

Once the plan has been deployed, the agent is configured with a generic default work-queue.
This default work-queue can be modified in the variables.tf file, as well as the default user.
The system can be accessed via the private key created as an output of running terraform.
 - Set permissions on the private key

`chmod 400 prefectAgentVM.pem`

 - As your public IP will be dynamic, retrieve the public IP from terraform output

`public_ip=$(terraform output -raw public_ip_address)`

 - SSH to your system

`ssh -i prefectAgentVM.pem azureuser@"$public_ip"`

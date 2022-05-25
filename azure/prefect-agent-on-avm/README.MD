This recipe is a basic configuration to setup an Azure VM and run the Prefect Agent.

Created as part of this recipe:
# Prefect Resource Group
# Prefect VNet
# Prefect Subnet
# A Network Interface with a dynamically assigned Public IP
# A Network Security Group that permits SSH from everywhere
# A storage account for boot diagnostics
# An Azure VM - authentication is via SSH key only.
# Prefect Agent is installed, and configured as a systemd service.

To use this recipe, ensure you have installed the following packages for your OS:
azure-cli
terraform

Once installed, you must login to Azure CLI as a user with permissions across the subscription:
az login

Once logged in, the following set of commands will pull down the providers, create the terraform plan, and apply the plan:
terraform init
terraform plan -out prefect_agent.out
terraform apply "prefect_agent.out"

Once the plan has been deployed, the agent is configured with a generic default work-queue.
The system can be accessed via the private key created as an output of running terraform.
# Set permissions on the private key
chmod 400 prefectAgentVM.pem
# As your public IP will be dynamic, retrieve the public IP from terraform output
public_ip=$(terraform output | grep public | awk '{print $3}' | sed 's/"//g')
# SSH to your system
ssh -i prefectAgentVM.pem azureuser@"$public_ip"

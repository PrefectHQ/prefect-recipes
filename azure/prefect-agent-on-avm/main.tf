# Create randomized resource group name in your designated region
resource "azurerm_resource_group" "rg" {
  name      = "rg-${var.resource_group_name}"
  location  = var.resource_group_location
}

# Create virtual network
resource "azurerm_virtual_network" "prefectnetwork" {
  name                = var.vnet_name
  address_space       = var.vnet_id
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Create subnet in  myVnet
resource "azurerm_subnet" "prefectsubnet" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.prefectnetwork.name
  address_prefixes     = var.subnet_id
}

#Create public IPs if public acccess is needed; this IS publicly exposed.
resource "azurerm_public_ip" "publicip" {
  name                = "myPublicIP"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
}

# Create Network Security Group and rule # Allow SSH inbound from all locations.
# If "*" is too open for your liking, you can determine your public IP via:
# curl ifconfig.co
#Replace source address prefix with the output from your curl command with /32 at the end.
#This limits scope to allow access via SSH only from your IP address; note unless you have a static 
# public IP address, this is strictly for dev use.

resource "azurerm_network_security_group" "myterraformnsg" {
  name                = "myNetworkSecurityGroup"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = var.default_nsg.name
    priority                   = var.default_nsg.priority
    direction                  = var.default_nsg.direction
    access                     = var.default_nsg.access
    protocol                   = var.default_nsg.protocol
    source_port_range          = var.default_nsg.source_port_range
    destination_port_range     = var.default_nsg.destination_port_range
    source_address_prefix      = var.default_nsg.source_address_prefix
    destination_address_prefix = var.default_nsg.destination_address_prefix
  }
}

# Create network interface ; assigned to the subnet, with the output of Public IP
resource "azurerm_network_interface" "publicnic" {
  name                = "myNIC"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "myNicConfiguration"
    subnet_id                     = azurerm_subnet.prefectsubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.publicip.id
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "nsg_assoc" {
  network_interface_id      = azurerm_network_interface.publicnic.id
  network_security_group_id = azurerm_network_security_group.myterraformnsg.id
}

# Generate random text for a unique storage account name (optional)
resource "random_id" "randomId" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = azurerm_resource_group.rg.name
  }

  byte_length = 8
}

# Create storage account for boot diagnostics (optional)
resource "azurerm_storage_account" "mystorageaccount" {
  name                     = "diag${random_id.randomId.hex}"
  location                 = azurerm_resource_group.rg.location
  resource_group_name      = azurerm_resource_group.rg.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Create an SSH key
resource "tls_private_key" "example_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create the private .pem key locally
resource "local_file" "ssh_key" {
  filename      = "${azurerm_linux_virtual_machine.prefectagentvm.name}.pem"
  content       = tls_private_key.example_ssh.private_key_pem
}

# Create virtual machine
resource "azurerm_linux_virtual_machine" "prefectagentvm" {
  name                  = "prefectAgentVM"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.publicnic.id]
  size                  = "Standard_DS1_v2"

  os_disk {
    name                 = "myOsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference{
      publisher = var.source_image.publisher
      offer     = var.source_image.offer
      sku       = var.source_image.sku
      version   = var.source_image.version
  }

  computer_name                   = "prefect-agentVM"
  admin_username                  = var.admin_user
  disable_password_authentication = true

  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.example_ssh.public_key_openssh
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.mystorageaccount.primary_blob_endpoint
  }
}

resource "azurerm_virtual_machine_extension" "vmext" {
  name                 = "${azurerm_linux_virtual_machine.prefectagentvm.computer_name}-vmext"
  virtual_machine_id   = azurerm_linux_virtual_machine.prefectagentvm.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
    {
        "script": "${base64encode(templatefile("vm_extension.sh.tpl", {
            adminuser = var.admin_user, defaultqueue = var.default_queue }))}"
    }
  SETTINGS

}

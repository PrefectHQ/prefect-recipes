# Create randomized resource group name in your designated region
resource "azurerm_resource_group" "rg" {
  name      = "rg-${var.resource_group_name}"
  location  = var.resource_group_location
}

# Create virtual network
resource "azurerm_virtual_network" "prefectnetwork" {
  name                = "prefectVnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Create subnet in  myVnet
resource "azurerm_subnet" "prefectsubnet" {
  name                 = "prefectSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.prefectnetwork.name
  address_prefixes     = ["10.0.1.0/24"]
}

#Create public IPs if public acccess is needed; this IS publicly exposed.
resource "azurerm_public_ip" "publicip" {
  name                = "myPublicIP"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
}

# Create Network Security Group and rule # Allow SSH inbound from all locations.
resource "azurerm_network_security_group" "myterraformnsg" {
  name                = "myNetworkSecurityGroup"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
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

# resource "azurerm_network_interface" "privatenic" {
#   name                = "privateNICIP"
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name

#   ip_configuration {
#     name                          = "internal"
#     subnet_id                     = azurerm_subnet.prefectsubnet.id
#     private_ip_address_allocation = "Dynamic"
#   }
# }

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

# Create (and display) an SSH key - Default is to mask SSH output, requires -raw or -json during terraform apply to display.
resource "tls_private_key" "example_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
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

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  computer_name                   = "prefect-agentVM"
  admin_username                  = "azureuser"
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
        "script": "IyEvYmluL2Jhc2gKCiNVcGRhdGUgcGFja2FnZXMKc3VkbyBhcHQtZ2V0IHVwZGF0ZSAteQoKI0luc3RhbGwgcGlwMwpzdWRvIGFwdCBpbnN0YWxsIHB5dGhvbjMtcGlwIC15CgojSW5zdGFsbCBsYXRlc3QgcHJlZmVjdApweXRob24zIC1tIHBpcCBpbnN0YWxsIC1VICJwcmVmZWN0Pj0yLjBiIgoKI1VwZGF0ZSBwYXRoCmV4cG9ydCBQQVRIPS91c3IvbG9jYWwvc2JpbjovdXNyL2xvY2FsL2JpbjovdXNyL3NiaW46L3Vzci9iaW46L3NiaW46L2Jpbjovc25hcC9iaW46L2hvbWUvYXp1cmV1c2VyLy5sb2NhbC9iaW4KCiNBZGQgcGF0aCB0byAuYmFzaHJjCmVjaG8gImV4cG9ydCBQQVRIPS91c3IvbG9jYWwvc2JpbjovdXNyL2xvY2FsL2JpbjovdXNyL3NiaW46L3Vzci9iaW46L3NiaW46L2Jpbjovc25hcC9iaW46L2hvbWUvYXp1cmV1c2VyLy5sb2NhbC9iaW4iID4+IC9ob21lL2F6dXJldXNlci8uYmFzaHJjCgojQ3JlYXRlIGEgZGVmYXVsdCB3b3JrLXF1ZXVlCi9ob21lL2F6dXJldXNlci8ubG9jYWwvYmluL3ByZWZlY3Qgd29yay1xdWV1ZSBjcmVhdGUgZGVmYXVsdAoKI0NyZWF0ZSB0aGUgc3lzdGVtZCBzZXJ2aWNlCnN1ZG8gY2F0IDw8IEVPRiA+IC9ldGMvc3lzdGVtZC9zeXN0ZW0vcHJlZmVjdC1hZ2VudC5zZXJ2aWNlCltVbml0XQpEZXNjcmlwdGlvbj1QcmVmZWN0IEFnZW50IFNlcnZpY2UKQWZ0ZXI9bmV0d29yay50YXJnZXQKU3RhcnRMaW1pdEludGVydmFsU2VjPTAKCltTZXJ2aWNlXQpUeXBlPXNpbXBsZQpSZXN0YXJ0PWFsd2F5cwpSZXN0YXJ0U2VjPTEKVXNlcj1henVyZXVzZXIKRXhlY1N0YXJ0PS9ob21lL2F6dXJldXNlci8ubG9jYWwvYmluL3ByZWZlY3QgYWdlbnQgc3RhcnQgZGVmYXVsdAoKW0luc3RhbGxdCldhbnRlZEJ5PWRlZmF1bHQudGFyZ2V0CkVPRgoKI0VuYWJsZSB0aGUgYWdlbnQgdG8gc3RhcnQgb24gc3lzdGVtIGJvb3QKc3VkbyBzeXN0ZW1jdGwgZW5hYmxlIHByZWZlY3QtYWdlbnQKCiNTdGFydCB0aGUgcHJlZmVjdC1hZ2VudCBzZXJ2aWNlCnN1ZG8gc3lzdGVtY3RsIHN0YXJ0IHByZWZlY3QtYWdlbnQK"
    }
  SETTINGS

#   settings = <<SETTINGS
#     {
#         "commandToExecute": "apt-get update -y"
#     }
#   SETTINGS

}

resource "local_file" "ssh_key" {
  filename      = "${azurerm_linux_virtual_machine.prefectagentvm.name}.pem"
  content       = tls_private_key.example_ssh.private_key_pem
}
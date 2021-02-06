terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "2.40.0"
    }
  }
}

# Provider in subs huyeduon-Demo05
provider "azurerm" {
    subscription_id = var.subscription_id
    client_id = var.client_id
    client_secret = var.client_secret
    tenant_id = var.tenant_id
    features {}
}

# Create resource group
resource "azurerm_resource_group" "tfRG" {
  name     = var.rgName
  location = var.location
}

# Create Network Security Group
resource "azurerm_network_security_group" "nsg1" {
  name                = var.nsgName
  location            = var.location
  resource_group_name = azurerm_resource_group.tfRG.name
}

# Create Security Rule allow ssh
resource "azurerm_network_security_rule" "ssh" {
  name                        = "ssh"
  priority                    = 1001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.tfRG.name
  network_security_group_name = azurerm_network_security_group.nsg1.name
}

# Create Security Rule allow http
resource "azurerm_network_security_rule" "http" {
  name                        = "http"
  priority                    = 1002
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.tfRG.name
  network_security_group_name = azurerm_network_security_group.nsg1.name
}


# Create a Virtual Network
resource "azurerm_virtual_network" "vnet1" {
  name                = var.vnetName
  location            = azurerm_resource_group.tfRG.location
  resource_group_name = azurerm_resource_group.tfRG.name
  address_space       = ["10.0.0.0/16"]
}

# Create subnet
resource "azurerm_subnet" "subnet1" {
  name                 = var.subnetName
  resource_group_name  = azurerm_resource_group.tfRG.name
  virtual_network_name = azurerm_virtual_network.vnet1.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create public IPs
resource "azurerm_public_ip" "publicip" {
    name                         = "myPublicIP"
    location                     = azurerm_resource_group.tfRG.location
    resource_group_name          = azurerm_resource_group.tfRG.name
    allocation_method            = "Static"
    sku                          = "Standard"

    tags = {
        type = "epg1"
    }
}

# Create network interface
resource "azurerm_network_interface" "nic01" {
  name                = "nic01"
  location            = azurerm_resource_group.tfRG.location
  resource_group_name = azurerm_resource_group.tfRG.name

  ip_configuration {
    name                          = "ip"
    subnet_id                     = azurerm_subnet.subnet1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.publicip.id
  }
}

# Associate nsg to nic
resource "azurerm_network_interface_security_group_association" "nsg_to_nic" {
  network_interface_id      = azurerm_network_interface.nic01.id
  network_security_group_id = azurerm_network_security_group.nsg1.id
}

# Create random string
resource "random_id" "randomId" {
  byte_length = 8
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "vmStorageAccount" {
    name                        = "diag${random_id.randomId.hex}"
    resource_group_name         = azurerm_resource_group.tfRG.name
    location                    = azurerm_resource_group.tfRG.location
    account_tier                = "Standard"
    account_replication_type    = "LRS"

    tags = {
        environment = "terraform"
    }
}


# Create a VM
resource "azurerm_virtual_machine" "vm" {
  name                  = "epg1-01"
  location              = "westus"
  resource_group_name   = azurerm_resource_group.tfRG.name
  network_interface_ids = [azurerm_network_interface.nic01.id]
  vm_size               = "Standard_B1ls"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "epg1-01"
    admin_username = var.admin_username
    admin_password = var.admin_password
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  boot_diagnostics {
    enabled = "true"
    storage_uri = azurerm_storage_account.vmStorageAccount.primary_blob_endpoint
  }
  tags = {
    epg = "epg1"
  }

  provisioner "file" {
    source      = "files/setup.sh"
    destination = "/home/${var.admin_username}/setup.sh"

    connection {
      type     = "ssh"
      user     = var.admin_username
      password = var.admin_password
      host     = azurerm_public_ip.publicip.ip_address
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/${var.admin_username}/setup.sh",
      "sudo /home/${var.admin_username}/setup.sh"
    ]
    connection {
      type     = "ssh"
      user     = var.admin_username
      password = var.admin_password
      host     = azurerm_public_ip.publicip.ip_address
    }
  }
}
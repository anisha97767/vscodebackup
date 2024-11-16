provider "azurerm" {
  features {}
  subscription_id="f1e3b015-103c-4241-ad7a-e7cdc1a522f9"
}
# Create Resource Group
resource "azurerm_resource_group" "rg02" {
  name     = "rg02"
  location = "East US"  # Change to your preferred location
}
 
# Create Virtual Network
resource "azurerm_virtual_network" "example" {
  name                = "example-vnet"
  address_space       = ["192.168.0.0/19"]
  location            = azurerm_resource_group.rg02.location
  resource_group_name = azurerm_resource_group.rg02.name
}
 
# Create Subnets
resource "azurerm_subnet" "subnet1" {
  name                 = "subnet1"
  resource_group_name  = azurerm_resource_group.rg02.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["192.168.0.0/24"] # 256 IPs
}
 
resource "azurerm_subnet" "subnet2" {
  name                 = "subnet2"
  resource_group_name  = azurerm_resource_group.rg02.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["192.168.1.0/24"] # 256 IPs
}
 
resource "azurerm_subnet" "subnet3" {
  name                 = "subnet3"
  resource_group_name  = azurerm_resource_group.rg02.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["192.168.2.0/24"] # 256 IPs
}
 
# Create Network Interface for Linux VM
resource "azurerm_network_interface" "linux_nic" {
  name                = "example-linux-nic"
  location            = azurerm_resource_group.rg02.location
  resource_group_name = azurerm_resource_group.rg02.name
 
  ip_configuration {
    name                          = "internal"
    subnet_id                    = azurerm_subnet.subnet1.id
    private_ip_address_allocation = "Dynamic"
  }
}
 
# Create Linux VM in the first subnet
resource "azurerm_linux_virtual_machine" "linux_vm" {
  name                = "example-linux-vm"
  resource_group_name = azurerm_resource_group.rg02.name
  location            = azurerm_resource_group.rg02.location
  size                = "Standard_DS1_v2"  # Choose a suitable VM size
  admin_username      = "adminuser"
  admin_password      = var.linux_admin_password  # Use a variable for better security
  network_interface_ids = [azurerm_network_interface.linux_nic.id]
 
  # OS Disk Configuration
  os_disk {
    name                  = "example-linux-os-disk"
    caching               = "ReadWrite"
    storage_account_type = "Standard_LRS"  # Add this required argument
    disk_size_gb          = 30  # Define the size of the OS disk
  }
 
  # Image Source
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "20.04-LTS"
    version   = "latest"
  }
 
  # Additional Data Disk (corrected block structure)
  data_disk {
    name            = "example-linux-data-disk"
    caching         = "None"
    create_option   = "Empty"
    disk_size_gb    = 2
    storage_account_type = "Standard_LRS"  # Add this required argument
  }
 
  tags = {
    environment = "dev"
  }
}
 
# Create Network Interface for Windows VM
resource "azurerm_network_interface" "windows_nic" {
  name                = "example-windows-nic"
  location            = azurerm_resource_group.rg02.location
  resource_group_name = azurerm_resource_group.rg02.name
 
  ip_configuration {
    name                          = "internal"
    subnet_id                    = azurerm_subnet.subnet2.id
    private_ip_address_allocation = "Dynamic"
  }
}
 
# Create Windows VM in the second subnet
resource "azurerm_windows_virtual_machine" "windows_vm" {
  name                = "example-windows-vm"
  resource_group_name = azurerm_resource_group.rg02.name
  location            = azurerm_resource_group.rg02.location
  size                = "Standard_DS1_v2"  # Choose a suitable VM size
  admin_username      = "adminuser"
  admin_password      = var.windows_admin_password  # Use a variable for better security
  network_interface_ids = [azurerm_network_interface.windows_nic.id]
 
  # OS Disk Configuration
  os_disk {
    name                  = "example-windows-os-disk"
    caching               = "ReadWrite"
    storage_account_type = "Standard_LRS"  # Add this required argument
    disk_size_gb          = 30  # Define the size of the OS disk
  }
 
  # Image Source
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }
 
  # Additional Data Disk (corrected block structure)
  data_disk {
    name            = "example-windows-data-disk"
    caching         = "None"
    create_option   = "Empty"
    disk_size_gb    = 2
    storage_account_type = "Standard_LRS"  # Add this required argument
  }
 
  tags = {
    environment = "dev"
  }
}
 
# Variable definitions for sensitive data (admin passwords)
variable "linux_admin_password" {
  description = "The admin password for the Linux VM"
  type        = string
  sensitive   = true
}
 
variable "windows_admin_password" {
  description = "The admin password for the Windows VM"
  type        = string
  sensitive   = true
}
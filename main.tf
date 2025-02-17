

provider "azurerm" {
  features {}

  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.region
}

# Create Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}

# Create Subnet
resource "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Generate Random Passwords
resource "random_password" "passwords" {
  count   = var.vm_count
  length  = 16
  special = false
}

# Deploy 14 Virtual Machines with Username & Password Authentication
resource "azurerm_linux_virtual_machine" "vm" {
  count               = var.vm_count
  name                = "vm-${count.index}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = random_password.passwords[count.index].result
  disable_password_authentication = false  # Ensures password authentication is enabled

  network_interface_ids = [azurerm_network_interface.nic[count.index].id]

  os_disk {
    name                 = "vm-${count.index}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS" # Standard HDD for S10 Disk
    disk_size_gb         = 128
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
}

# Create Network Interfaces for each VM (Without Public IP)
resource "azurerm_network_interface" "nic" {
  count               = var.vm_count
  name                = "vm-${count.index}-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Deploy MySQL Flexible Server
resource "azurerm_mysql_flexible_server" "mysql" {
  name                   = var.mysql_server_name
  resource_group_name    = azurerm_resource_group.rg.name
  location               = azurerm_resource_group.rg.location
  administrator_login    = "mysqladmin"
  administrator_password = random_password.mysql_password.result
  sku_name               = "GP_Standard_D2ds_v4"
  storage {
    size_gb = 100
  }
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
}

# Generate Random Password for MySQL
resource "random_password" "mysql_password" {
  length  = 16
  special = false
}

# Save VM Credentials Locally (Without Public IP)
resource "local_file" "vm_credentials" {
  content  = join("\n", [for i in range(var.vm_count) : "VM-${i} | User: ${var.admin_username} | Password: ${random_password.passwords[i].result} | Private IP: ${azurerm_network_interface.nic[i].private_ip_address}"])
  filename = "${path.module}/vm_credentials.txt"
}

# Save MySQL Credentials Locally
resource "local_file" "mysql_credentials" {
  content  = "MySQL Server: ${azurerm_mysql_flexible_server.mysql.fqdn} | User: mysqladmin | Password: ${random_password.mysql_password.result}"
  filename = "${path.module}/mysql_credentials.txt"
}


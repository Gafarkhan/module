provider "azurerm" {
  features {}

  client_id       = "bea6c1aa-aec9-461b-a0bf-09c8fcede6d9"
  client_secret   = "T7G8Q~VBfl4NrWKTKWPmAuQHOuqia9kLzem8qbVf"
  tenant_id       = "c4d10af2-b721-4268-981e-87e9fd52cc5b"
  subscription_id = "341a1c60-cd37-4bab-8e4c-9c0e5116371f"
}

resource "azurerm_resource_group" "rg" {
  name     = var.azurerm_resource_group
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = var.azurerm_virtual_network
  address_space       = var.address_space
  location            = var.location
  resource_group_name = var.azurerm_resource_group
  depends_on = [azurerm_resource_group.rg]
}

resource "azurerm_subnet" "subnet1" {
  name                 = var.subnet1
  resource_group_name  = var.azurerm_resource_group
  virtual_network_name = var.azurerm_virtual_network
  address_prefixes     = var.address_prefixes1
  depends_on = [azurerm_virtual_network.vnet]
}

resource "azurerm_subnet" "subnet2" {
  name                 = var.subnet2
  resource_group_name  = var.azurerm_resource_group
  virtual_network_name = var.azurerm_virtual_network
  address_prefixes     = var.address_prefixes2
  depends_on = [azurerm_virtual_network.vnet]
}

resource "azurerm_network_security_group" "Nsg" {
  name                = var.azurerm_network_security_group
  location            = var.location
  resource_group_name = var.azurerm_resource_group
  depends_on = [azurerm_virtual_network.vnet]

  security_rule {
    name                       = "test123"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "Dev"
  }
}

resource "azurerm_network_interface" "NIC" {
  name                = var.azurerm_network_interface
  location            = var.location
  resource_group_name = var.azurerm_resource_group

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.subnet1.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "VM1" {
  name                  = var.azurerm_virtual_machine
  location              = var.location
  resource_group_name   = var.azurerm_resource_group
  network_interface_ids = [azurerm_network_interface.NIC.id]
  vm_size               = "Standard_DS1_v2"
  depends_on = [azurerm_network_security_group.Nsg]

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "staging"
  }
}

resource "azurerm_public_ip" "pip" {
  name                = var.public_ip
  location            = var.location
  resource_group_name = var.azurerm_resource_group
  allocation_method   = "Static"
}

resource "azurerm_lb" "example" {
  name                = var.azurerm_LB
  location            = var.location
  resource_group_name = var.azurerm_resource_group
  depends_on = [azurerm_virtual_machine.VM1]

  frontend_ip_configuration {
    name                 = var.frontend_ip_configuration
    public_ip_address_id = azurerm_public_ip.pip.id
  }
}




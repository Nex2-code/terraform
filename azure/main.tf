provider "azurerm" {
    features {
    }
}
resource "azurerm_resource_group" "rg" {
    name = "k8s-test"
    location = "southindia"
}
resource "azurerm_virtual_network" "vnet" {
    name = "k8s-test-vnet"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    address_space = ["10.0.0.0/16"]
}
resource "azurerm_subnet" "subnet1" {
    name = "k8s-test-subnet1"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes = ["10.0.2.0/24"]
  
}

resource "azurerm_network_security_group" "vnet_sg" {
    name = "k8s-test-sg"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
}
resource "azurerm_network_interface" "nic" {
    name = "k8s-test-nic"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

    ip_configuration {
      name = "k8s-test-internal"
      subnet_id = azurerm_subnet.subnet1.id
      private_ip_address_allocation = "Dynamic"
      public_ip_address_id = azurerm_public_ip.masterip.id
    }
}
resource "azurerm_linux_virtual_machine" "master-vm" {
    name = "master"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    size = "Standard_B2als_v2"
    admin_username = "adminuser"
    network_interface_ids = [
        azurerm_network_interface.nic.id
    ]
    admin_ssh_key {
      username = "adminuser"
      public_key = file("~/.ssh/id_rsa.pub")
    }
    os_disk {
      caching = "ReadWrite"
      storage_account_type = "Standard_LRS"
    }
    source_image_reference {
      publisher = "Canonical"
      offer = "0001-com-ubuntu-server-focal"
      sku = "20_04-lts"
      version = "latest"
    }
}
resource "azurerm_network_interface" "nic1" {
    name = "k8s-test-nic1"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

    ip_configuration {
      name = "k8s-test-internal1"
      subnet_id = azurerm_subnet.subnet1.id
      private_ip_address_allocation = "Dynamic"
      public_ip_address_id = azurerm_public_ip.workerip.id
    }
}
resource "azurerm_linux_virtual_machine" "worker-vm" {
    name = "worker"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    size = "Standard_B2als_v2"
    admin_username = "adminuser"
    network_interface_ids = [
        azurerm_network_interface.nic1.id
    ]
    admin_ssh_key {
      username = "adminuser"
      public_key = file("~/.ssh/id_rsa.pub")
    }
    os_disk {
      caching = "ReadWrite"
      storage_account_type = "Standard_LRS"
    }
    source_image_reference {
      publisher = "Canonical"
      offer = "0001-com-ubuntu-server-focal"
      sku = "20_04-lts"
      version = "latest"
    }
}
resource "azurerm_public_ip" "masterip" {
    name = "masterip"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    allocation_method = "Dynamic"
  
}
resource "azurerm_public_ip" "workerip" {
    name = "workerip"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    allocation_method = "Dynamic"
  
}
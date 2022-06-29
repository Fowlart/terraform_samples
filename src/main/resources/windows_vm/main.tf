terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.11.0"
    }
  }
}

provider "azurerm" {
  features {
  }
}

# creates resource group
resource "azurerm_resource_group" "main" {
  location = "NorthEurope"
  name     = "tf_created_group"
}

resource "azurerm_virtual_network" "main" {
  address_space = ["10.0.0.0/16"]
  location      = azurerm_resource_group.main.location
  name          = "virtual_network_for_virtual_machine"
  # resource group was created and it is possible for refer it as a variable
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "main" {

  name                 = "subnet_for_virtual_network_for_virtual_machine"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_network_interface" "internal" {
  location            = azurerm_resource_group.main.location
  name                = "ni_internal"
  resource_group_name = azurerm_resource_group.main.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "main" {
  name                  = "windows-vm-01"
  resource_group_name   = azurerm_resource_group.main.name
  admin_password        = "666adminAstrAtAr666"
  admin_username        = "adminAstrAtAr"
  location              = azurerm_resource_group.main.location
  network_interface_ids = [azurerm_network_interface.internal.id]
  size                  = "Standard_B1s"
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    offer     = "WindowsServer"
    publisher = "MicrosoftwindowsServer"
    sku       = "2016-DataCenter"
    version   = "latest"
  }
}
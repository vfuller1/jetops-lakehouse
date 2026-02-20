# Rycrawl Test Windows Server VM
resource "azurerm_windows_virtual_machine" "rycrawl_test" {
  name                = "vm-rycrawl-test"
  resource_group_name = azurerm_resource_group.aviator.name
  location            = azurerm_resource_group.aviator.location
  size                = "Standard_DS2_v2"
  admin_username      = var.rycrawl_admin_username
  admin_password      = var.rycrawl_admin_password
  network_interface_ids = [azurerm_network_interface.rycrawl_test_nic.id]
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name                 = "osdisk-rycrawl-test"
  }
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter"
    version   = "latest"
  }
}

# Network Interface for the VM
resource "azurerm_network_interface" "rycrawl_test_nic" {
  name                = "nic-rycrawl-test"
  location            = azurerm_resource_group.aviator.location
  resource_group_name = azurerm_resource_group.aviator.name
  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.rycrawl_test_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.rycrawl_test_public_ip.id
  }
}

# Public IP for the VM (for internet access)
resource "azurerm_public_ip" "rycrawl_test_public_ip" {
  name                = "pip-rycrawl-test"
  location            = azurerm_resource_group.aviator.location
  resource_group_name = azurerm_resource_group.aviator.name
  allocation_method   = "Dynamic"
  sku                 = "Basic"
}

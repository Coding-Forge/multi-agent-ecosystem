resource "azurerm_public_ip" "pip" {
  name                = "${var.vm_name}-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"

  tags = {
    environment = "dev"
  }
}

module "devbox_nic"{
  source = "../azurerm/resource/networkinterfaces"
  environment = var.environment
  location = var.location
  network_interface_name = var.nic_name
  ip_configuration_name = var.ip_configuration_name
  resource_group_name = var.resource_group_name
  subnet_name = var.subnet_name
  vnet_name = var.vnet_name
  has_public_ip = var.vm_has_public_ip
  public_ip_address_id = azurerm_public_ip.pip.id
  subnet_id = var.subnet_id
  
  tags = {
    environment = "dev"
  }
}

resource "azurerm_network_security_rule" "allow_ssh" {
  name                        = "AllowSSH"
  priority                    = 1001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = var.network_security_group_name
}

resource "azurerm_network_security_rule" "allow_rdp" {
  name                        = "AllowRDP"
  priority                    = 1010
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = var.network_security_group_name
}

resource "azurerm_linux_virtual_machine" "devbox-vm" {
  name                  = "${var.vm_name}"
  resource_group_name   = var.resource_group_name
  location              = var.location
  size                  = var.vm_size
  admin_password        = var.vm_admin_password
  admin_username        = var.vm_admin_username
  network_interface_ids = [
    module.devbox_nic.network_interface_id
  ]

  custom_data = filebase64("${path.module}/scripts/custom_data.tpl")

  identity {
    type = "SystemAssigned"
  }

  admin_ssh_key {
    username   = var.vm_admin_username
    public_key = file("~/.ssh/devbox.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  provisioner "local-exec" {
    command = templatefile("${path.module}/scripts/${var.host_os}-ssh-scripts.tpl", {
      hostname     = self.public_ip_address,
      user         = var.vm_admin_username,
      identityfile = "~/.ssh/devbox"
    })
    interpreter = var.host_os == "linux" ? ["bash", "-c"] : ["Powershell", "-Command"]
  }

  tags = {
    environment = "dev"
  }
}

data "azurerm_public_ip" "chat-ip-data" {
  name                = azurerm_public_ip.pip.name
  resource_group_name = var.resource_group_name
}

resource "azurerm_virtual_machine_extension" "aad_login" {
  name                 = "AADLoginForLinux"
  virtual_machine_id   = azurerm_linux_virtual_machine.devbox-vm.id
  publisher            = "Microsoft.Azure.ActiveDirectory.LinuxSSH"
  type                 = "AADLoginForLinux"
  type_handler_version = "1.0"
  auto_upgrade_minor_version = true
  settings = jsonencode(
    {
        "username": "${var.vm_admin_username}",
        "ssh_key": "${file("~/.ssh/devbox.pub")}"
    })
}

output "public_ip_address" {
  value = "${azurerm_linux_virtual_machine.devbox-vm.name}: ${data.azurerm_public_ip.chat-ip-data.ip_address}"
  # value = "${azurerm_windows_virtual_machine.devbox-vm.name}: ${data.azurerm_public_ip.chat-ip-data.ip_address}"
}

output "admin_username" {
  value = var.vm_admin_username
}
output "admin_password" {
  value = var.vm_admin_password
}

output "name" {
  value = azurerm_linux_virtual_machine.devbox-vm.name
}

# resource "azurerm_virtual_network" "vnet" {
#   name                = "${azurerm_resource_group.rg.name}-vnet"
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name
#   address_space       = ["10.123.0.0/16"]

#   tags = {
#     environment = "dev"
#   }
# }

# resource "azurerm_subnet" "subnet" {
#   name                 = "${azurerm_resource_group.rg.name}-subnet"
#   resource_group_name  = azurerm_resource_group.rg.name
#   virtual_network_name = azurerm_virtual_network.vnet.name
#   address_prefixes     = ["10.123.1.0/24"]
# }

# resource "azurerm_subnet_network_security_group_association" "nsg_association" {
#   subnet_id                 = azurerm_subnet.subnet.id
#   network_security_group_id = azurerm_network_security_group.nsg.id
# }

# resource "azurerm_public_ip" "pip" {
#   name                = "${azurerm_resource_group.rg.name}-pip"
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name
#   allocation_method   = "Dynamic"

#   tags = {
#     environment = "dev"
#   }
# }

# resource "azurerm_network_interface" "nic" {
#   name                = "${azurerm_resource_group.rg.name}-nic"
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name

#   ip_configuration {
#     name                          = "${azurerm_resource_group.rg.name}-ipconfig"
#     subnet_id                     = azurerm_subnet.subnet.id
#     private_ip_address_allocation = "Dynamic"
#     public_ip_address_id          = azurerm_public_ip.pip.id
#   }

#   tags = {
#     environment = "dev"
#   }
# }



# resource "azurerm_network_interface" "nic" {
#   name                = "${azurerm_resource_group.rg.name}-nic"
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name

#   ip_configuration {
#     name                          = "${azurerm_resource_group.rg.name}-ipconfig"
#     subnet_id                     = module.subnet[var.subnet_deployment[0].name].subnet_id
#     private_ip_address_allocation = "Dynamic"
#     public_ip_address_id          = azurerm_public_ip.pip.id
#   }

#   tags = {
#     environment = "dev"
#   }
# }

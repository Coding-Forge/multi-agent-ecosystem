resource "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.vnet_name
  address_prefixes     = [var.subnet_address_space]


  # is there a way to logically add a delegation to the subnet?
  dynamic "delegation" {
    for_each = var.enable_delegation ? [1] : []
    content {
      name = "web-server-farm"
      service_delegation {
        name = "Microsoft.Web/serverFarms"
        actions = [
          "Microsoft.Network/virtualNetworks/subnets/join/action",
          "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
        ]
      }
    }
  }
}

resource "azurerm_network_security_group" "subnet_nsg" {
  name                = "${azurerm_subnet.subnet.name}-nsg"
  location            = var.location
  resource_group_name = azurerm_subnet.subnet.resource_group_name
}

resource "azurerm_subnet_network_security_group_association" "subnet_nsg_association" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.subnet_nsg.id
}

output "subnet_id" {
  value = azurerm_subnet.subnet.id
}
output "subnet_name" {
  value = azurerm_subnet.subnet.name
}
output "network_security_group_id" {
  value = azurerm_network_security_group.subnet_nsg.id
}
output "network_security_group_name" {
  value = azurerm_network_security_group.subnet_nsg.name
}
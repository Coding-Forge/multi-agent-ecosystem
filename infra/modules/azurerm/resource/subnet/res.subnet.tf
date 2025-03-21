resource "azurerm_subnet" "subnet" {
    name                 = var.subnet_name
    resource_group_name  = var.resource_group_name
    virtual_network_name = var.vnet_name
    address_prefixes     = [var.subnet_address_space]
}

output "subnet_id" {
    value = azurerm_subnet.subnet.id
}
output "subnet_name" {
    value = azurerm_subnet.subnet.name
}

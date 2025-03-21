resource "azurerm_virtual_network" "vnet" {
    count               = var.deploy_vnet ? 1 : 0
    name                = var.vnet_name
    address_space       = [var.vnet_address_space]
    location            = var.location
    resource_group_name = var.resource_group_name
    tags                = merge(
        var.tags,
        {
            environment = var.environment
        }
    )
}
output "vnet_id" {
    value = azurerm_virtual_network.vnet[0].id
}
output "vnet_name" {
    value = azurerm_virtual_network.vnet[0].name
}
output "vnet_address_space" {
    value = azurerm_virtual_network.vnet[0].address_space
}
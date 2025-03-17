resource "azurerm_virtual_network" "vnet" {
    count               = var.deploy_vnet ? 1 : 0
    name                = var.vnet_name
    address_space       = var.vnet_address_space
    location            = var.location
    resource_group_name = var.resource_group_name
    tags                = merge(
        var.tags,
        {
            environment = var.environment
        }
    )
}
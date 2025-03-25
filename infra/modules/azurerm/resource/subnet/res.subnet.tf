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
                name    = "Microsoft.Web/serverFarms"
                actions = [
                    "Microsoft.Network/virtualNetworks/subnets/join/action",
                    "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
                ]
            }
        }
    }
}

output "subnet_id" {
    value = azurerm_subnet.subnet.id
}
output "subnet_name" {
    value = azurerm_subnet.subnet.name
}

resource azurerm_network_interface "network_interface" {
  name                = var.network_interface_name
  location            = var.location
  resource_group_name = var.resource_group_name
  ip_configuration {
    name                          = var.ip_configuration_name
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.has_public_ip ? var.public_ip_address_id : null 
    
  }
  tags = merge(
    var.tags,
    {
      environment = var.environment
    }
  )
}

output "network_interface_id" {
  value = azurerm_network_interface.network_interface.id
}
output "network_interface_name" {
  value = azurerm_network_interface.network_interface.name
}
output "network_interface_private_ip" {
  value = azurerm_network_interface.network_interface.ip_configuration[0].private_ip_address
}
output "network_interface_public_ip" {
  value = azurerm_network_interface.network_interface.ip_configuration[0].public_ip_address_id
}
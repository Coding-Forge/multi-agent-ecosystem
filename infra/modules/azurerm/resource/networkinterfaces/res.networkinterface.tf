resource azurerm_network_interface "network_interface" {
  name                = var.network_interface_name
  location            = var.location
  resource_group_name = var.resource_group_name
  ip_configuration {
    name                          = var.ip_configuration_name
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    
  }
  tags = merge(
    var.tags,
    {
      environment = var.environment
    }
  )
}
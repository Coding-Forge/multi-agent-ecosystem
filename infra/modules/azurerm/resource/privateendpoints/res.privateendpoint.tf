resource azurerm_private_endpoint "private_endpoint" {
  count               = var.deploy_private_endpoint ? 1 : 0
  name                = var.private_endpoint_name
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = var.private_service_connection_name
    private_connection_resource_id = var.private_connection_resource_id
    is_manual_connection           = false
    subresource_names              = var.subresource_names
  }

  tags = merge(
    var.tags,
    {
      environment = var.environment
    }
  )
}
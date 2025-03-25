resource "azurerm_storage_account" "storage_account" {
  name                     = var.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_account_replication
  public_network_access_enabled = var.deploy_vnet ? false : true
  tags = merge(
    var.tags,
    {
      environment = var.environment
    }
  )
}

resource "azurerm_storage_container" "storage_container" {
  name                  = var.storage_container_name
  storage_account_id = azurerm_storage_account.storage_account.id
  container_access_type = "private"
}

# resource "azurerm_storage_blob" "storage_blob" {
#   name                   = var.storage_blob_name
#   storage_account_name   = azurerm_storage_account.storage_account.name
#   storage_container_name = azurerm_storage_container.storage_container.name
#   type                   = "Block"
# }
output "storage_account_name" {
  value = azurerm_storage_account.storage_account.name
}
output "primary_access_key" {
  value = azurerm_storage_account.storage_account.primary_access_key
}
output "storage_connection_string" {
  value = azurerm_storage_account.storage_account.primary_connection_string
}
output "storage_account_id" {
  value = azurerm_storage_account.storage_account.id
}
output "storage_container_id" {
  value = azurerm_storage_container.storage_container.id
}
output "storage_container_name" {
  value = azurerm_storage_container.storage_container.name
}
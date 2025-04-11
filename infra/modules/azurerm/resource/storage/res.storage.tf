resource "azurerm_storage_account" "storage_account" {
  name                     = var.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_account_replication
  
  network_rules {
    default_action = var.public_network_access_enabled ? "Allow" : "Deny"
    bypass         = ["AzureServices"]
    ip_rules = var.public_network_access_enabled ? [] : [
      "108.196.164.24"
    ]
  }

  tags = merge(
    var.tags,
    {
      environment = var.environment
    }
  )
}

resource "azurerm_storage_container" "storage_container" {
  name                  = var.storage_container_name
  storage_account_id    = azurerm_storage_account.storage_account.id
  container_access_type = "private"
}

output "storage_account_name" {
  value = azurerm_storage_account.storage_account.name
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
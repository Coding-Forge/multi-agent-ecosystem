resource "azurerm_linux_web_app_slot" "web_app_slot" {
  name                  = "${var.web_app_name}-${var.slot_name}"
  app_service_id        = var.app_service_id
  service_plan_id       = var.app_service_id
  app_settings          = var.app_settings
  site_config {
  }
  identity {
    type = "SystemAssigned"
  }
} 
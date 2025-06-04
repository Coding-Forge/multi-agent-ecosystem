resource "azurerm_linux_web_app" "web_app" {
  name                                           = var.web_app_name
  resource_group_name                            = var.resource_group_name
  location                                       = var.resource_group_location
  service_plan_id                                = var.service_plan_id
  ftp_publish_basic_authentication_enabled       = false
  https_only                                     = true
  public_network_access_enabled                  = var.public_network_access_enabled ? false : true
  virtual_network_subnet_id                      = module.subnet[var.subnet_deployment[1].name].subnet_id
  webdeploy_publish_basic_authentication_enabled = false
  app_settings = var.app_settings

  site_config {
    always_on                         = var.site_config.always_on
    http2_enabled                     = var.site_config.http2_enabled
    ip_restriction_default_action     = var.site_config.ip_restriction_default_action
    scm_ip_restriction_default_action = var.site_config.scm_ip_restriction_default_action
    use_32_bit_worker                 = var.site_config.use_32_bit_worker
    vnet_route_all_enabled            = var.site_config.vnet_route_all_enabled
    app_command_line                  = var.site_config.app_command_line
    cors {
      allowed_origins     = var.site_config.cors.allowed_origins
      support_credentials = var.site_config.cors.support_credentials
    }
    application_stack {
      python_version = var.site_config.application_stack.python_version
    }
  }
  
  identity {
    type = var.identity.type
  }
  tags = var.tags
  lifecycle {
    ignore_changes = var.lifecycle.ignore_changes
  }
  logs {
    detailed_error_messages = var.logs.detailed_error_messages
    failed_request_tracing  = var.logs.failed_request_tracing
    application_logs {
      file_system_level = var.logs.application_logs.file_system_level
    }    
    http_logs {
      file_system {
        retention_in_days = var.logs.http_logs.file_system.retention_in_days
        retention_in_mb   = var.logs.http_logs.file_system.retention_in_mb
      }
    }
  }
}

output "web_app_id" {
  description = "The ID of the web app."
  value       = azurerm_linux_web_app.web_app.id
}
variable "web_app_name" {
  description = "The name of the web app."
  type        = string
}

variable "service_plan_id" {
  description = "The ID of the service plan to which the web app will be associated."
  type        = string
}

variable "app_settings" {
  description = "A map of application settings for the web app."
  type        = map(string)
  default     = {}
}

variable "resource_group_name" {
  description = "The name of the resource group where the web app will be created."
  type        = string
}

variable "resource_group_location" {
  description = "The location of the resource group."
  type        = string
}

variable "public_network_access_enabled" {
  description = "Whether public network access is enabled for the web app."
  type        = bool
  default     = true
}

variable "environment" {
  description = "The environment in which the web app is deployed."
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the web app."
  type        = map(string)
  default     = {}
}

variable "site_config" {
  description = "Configuration for the web app's site."
  type = object({
    always_on                         = bool
    http2_enabled                     = bool
    ip_restriction_default_action     = string
    scm_ip_restriction_default_action = string
    use_32_bit_worker                 = bool
    vnet_route_all_enabled            = bool
    app_command_line                  = string
    cors                              = object({
      allowed_origins     = list(string)
      support_credentials = bool
    })
    application_stack                 = object({
      python_version = string
    })
  })
}

variable "identity" {
  description = "The identity configuration for the web app."
  type = string
  default = "SystemAssigned"
}

variable "lifecycle" {
  description = "Lifecycle rules for the web app."
  type = object({
    ignore_changes = list(string)
  })
  default = {
    ignore_changes = []
  }
}

variable "logs" {
  description = "Logging configuration for the web app."
  type = object({
    detailed_error_messages = bool
    failed_request_tracing  = bool
    application_logs = object({
      file_system_level = string
    })
    http_logs = object({
      file_system = object({
        retention_in_days = number
        retention_in_mb   = number
      })
    })
  })
  default = {
    detailed_error_messages = true
    failed_request_tracing  = true
    application_logs = {
      file_system_level = "Verbose"
    }
    http_logs = {
      file_system = {
        retention_in_days = 1
        retention_in_mb   = 35
      }
    }
  }
}
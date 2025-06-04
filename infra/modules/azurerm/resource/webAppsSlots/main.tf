variable "web_app_name" {
  description = "The name of the web app."
  type        = string
}

variable "slot_name"{
  description = "The name of the slot for the web app."
  type        = string
}

variable "app_service_id" {
  description = "The ID of the app service to which the slot belongs."
  type        = string
}

variable "service_plan_id" {
  description = "The ID of the service plan to which the web app slot will be associated."
  type        = string
}

variable "app_settings" {
  description = "A map of application settings for the web app slot."
  type        = map(string)
  default     = {}
}

variable "identity_type" {
  description = "The identity configuration for the web app slot."
  type = string
  default = "SystemAssigned"
}


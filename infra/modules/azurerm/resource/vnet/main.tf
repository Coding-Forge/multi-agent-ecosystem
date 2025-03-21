variable "deploy_vnet" {
  type    = bool
  default = false
}
variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}
variable "location" {
  description = "The Azure region where the resources will be created"
  type        = string
}
variable "vnet_address_space" {
  description = "The address space for the virtual network"
  type        = string
}
variable "tags" {
  description = "Tags to be applied to the resources"
  type        = map(string)
  default     = {}
}
variable "environment" {
  description = "The environment (e.g., dev, prod)"
  type        = string
}
variable "vnet_name" {
  description = "The name of the virtual network"
  type        = string
}

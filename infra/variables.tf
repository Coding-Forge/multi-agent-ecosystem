variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}
variable "location" {
  description = "The Azure region where the resources will be created"
  type        = string
}
variable "deploy_vnet" {
  type    = bool
  default = false
}
variable "tenant_id" {
  description = "The Azure tenant ID"
  type        = string
}
variable "subscription_id" {
  description = "The Azure subscription ID"
  type        = string
}
variable "client_id" {
  description = "The Azure client ID"
  type        = string
}
variable "client_secret" {
  description = "The Azure client secret"
  type        = string
}
variable "environment" {
  description = "The environment (e.g., dev, prod)"
  type        = string
}
variable "vnet_address_space" {
  description = "The address space for the virtual network"
  type        = list(string)
}
variable "subnet_name" {
  description = "The name of the subnet"
  type        = string
}
variable "subnet_prefix" {
  description = "The address prefix for the subnet"
  type        = list(string)
}
variable "tags" {
  description = "Tags to be applied to the resources"
  type        = map(string)
  default     = {}
}
variable "vnet_name" {
  description = "The name of the virtual network"
  type        = string
}
variable "subnet_address_space" {
  description = "The address space for the virtual network"
  type        = list(string)
}
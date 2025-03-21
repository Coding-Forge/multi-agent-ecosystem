variable "deploy_vnet" {
  description = "The number of instances to create"
  type        =  bool
  default     = false
}
variable "location" {
  description = "The Azure region where the resources will be created"
  type        = string
}
variable "resource_group_name" {
  description = "The name of the resource group"
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
variable "subnet_name" {
  description = "The name of the subnet"
  type        = string
}
variable "ip_configuration_name" {
  description = "The name of the IP configuration"
  type        = string
  default = "internal"
}
variable "network_interface_name" {
  description = "The name of the network interface"
  type        = string
  default     = "internal"
}
variable "subnet_id" {
  description = "The ID of the subnet"
  type        = string
}
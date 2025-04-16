variable "host_os" {
  description = "The host operating system for the DevBox."
  type        = string
  default     = "linux"
}
variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string
  default     = "DevBox"
}
variable "location" {
  description = "The Azure region where the resources will be created."
  type        = string
  default     = "East US"
}
variable "vnet_name" {
  description = "The name of the virtual network."
  type        = string
  default     = "DevBoxVNet"
}
variable "subnet_name" {
  description = "The name of the subnet."
  type        = string
  default     = "DevBoxSubnet"
}
variable "subnet_id" {
  description = "The ID of the subnet."
  type        = string
}
variable "network_security_group_name" {
  description = "The name of the network security group."
  type        = string
  default     = "DevBoxNSG"
}
variable "vm_name" {
  description = "The name of the virtual machine."
  type        = string
  default     = "DevBoxVM"
}
variable "vm_size" {
  description = "The size of the virtual machine."
  type        = string
  default     = "Standard_DS1_v2"
}
variable "vm_admin_username" {
  description = "The admin username for the virtual machine."
  type        = string
  default     = "azureuser"
}
variable "vm_admin_password" {
  description = "The admin password for the virtual machine."
  type        = string
  default     = "P@ssw0rd1234!"
}   
variable "nic_name" {
  description = "The name of the network interface."
  type        = string
  default     = "DevBoxNIC"
}
variable "environment" {
  description = "The environment (e.g., dev, prod)."
  type        = string
  default     = "dev"
}
variable "ip_configuration_name" {
  description = "The name of the IP configuration."
  type        = string
  default     = "internal"
}
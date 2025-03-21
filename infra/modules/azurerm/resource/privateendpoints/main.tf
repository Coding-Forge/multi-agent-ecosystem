variable "deploy_private_endpoint" {
  type    = bool
  default = false
}
variable "private_endpoint_name" {
  description = "The name of the private endpoint"
  type        = string
}
variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}
variable "location" {
  description = "The Azure region where the resources will be created"
  type        = string
}
variable "private_service_connection_name" {
  description = "The name of the private service connection"
  type        = string
}
variable "private_connection_resource_id" {
  description = "The ID of the subnet for the private connection"
  type        = string
}
variable "subresource_names" {
  description = "The subresource names for the private connection"
  type        = list(string)
  
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
variable "subnet_id" {
  description = "The ID of the subnet for the private endpoint"
  type        = string
}

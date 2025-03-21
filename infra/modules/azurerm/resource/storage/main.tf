variable "environment" {
  description = "The environment (e.g., dev, prod)"
  type        = string
  default = "dev"
}
variable "deploy_vnet" {
  description = "Flag to deploy the storage account"
  type        = bool
  default     = true
}
variable "tags" {
  description = "Tags to be applied to the resources"
  type        = map(string)
  default     = {}
}
variable "location" {
  description = "The Azure region where the resources will be created"
  type        = string
}
variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}
variable "storage_account_name" {
  description = "The name of the storage account"
  type        = string
}
variable "storage_container_name" {
  description = "The name of the storage container"
  type        = string
}
variable "storage_account_tier" {
  description = "The performance tier of the storage account"
  type        = string
  default     = "Standard"
}
variable "storage_account_replication" {
  description = "The replication type of the storage account"
  type        = string
  default     = "LRS"
}
variable "storage_account_kind" {
  description = "The kind of the storage account"
  type        = string
  default     = "StorageV2"
}
variable "storage_blob_name" {
  description = "The name of the blob"
  type        = string
}
variable "public_network_access_enabled" {
  description = "Flag to enable public network access"
  type        = bool
  default     = true
}
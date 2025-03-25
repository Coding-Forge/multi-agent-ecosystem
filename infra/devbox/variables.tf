variable "host_os" {
  type    = string
  default = "linux"
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
  default     = "my-resource-group"
}

variable "location" {
  description = "The region that you want the resource group created in"
  type        = string
  default     = "East US"
}
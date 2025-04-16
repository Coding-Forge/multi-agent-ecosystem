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
  type        = string
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

variable "search_service_name" {
  description = "The name of the Azure Cognitive Search service"
  type        = string
}
variable "search_service_sku" {
  description = "The SKU of the Azure Cognitive Search service"
  type        = string
}

variable "subnet_deployment" {
  description = "The subnet deployment configuration"
  type = list(object({
    name              = string
    address           = string
    enable_delegation = optional(bool)
    # security   = string
    # nsg        = string
    # public_ip  = string
    # private_ip = string
  }))
}

variable "openai_deployments" {
  description = "The OpenAI deployments to be created"
  type = list(object({
    name = string
    model = object({
      name    = string
      version = string

    })
    scale = object({
      type     = string
      capacity = number
    })
    rai_policy_name = string
  }))
}

#########################################################
# Storage Variables
#########################################################

variable "storage_account_name" {
  description = "The name of the storage account"
  type        = string
}

variable "storage_container_name" {
  description = "The name of the storage container"
  type        = string
}
variable "storage_blob_name" {
  description = "The name of the storage blob"
  type        = string
}

#########################################################
# VM Variables
#########################################################
variable "vm_name" {
  description = "The name of the VM"
  type        = string
}
variable "vm_size" {
  description = "The size of the VM"
  type        = string
}
variable "vm_admin_username" {
  description = "The admin username for the VM"
  type        = string
}
variable "vm_admin_password" {
  description = "The admin password for the VM"
  type        = string
}
variable "vm_nic_name" {
  description = "The name of the network interface"
  type        = string
}
variable "vm_ip_configuration_name" {
  description = "The name of the IP configuration"
  type        = string
}
# variable "vm_image_publisher" {
#   description = "The publisher of the VM image"
#   type        = string
# }
# variable "vm_image_offer" {
#   description = "The offer of the VM image"
#   type        = string

# }
# variable "vm_image_sku" {
#   description = "The SKU of the VM image"
#   type        = string
# }
# variable "vm_image_version" {
#   description = "The version of the VM image"
#   type        = string
# }
# variable "vm_public_ip" {
#   description = "The public IP address of the VM"
#   type        = string
# }
# variable "vm_private_ip" {
#   description = "The private IP address of the VM"
#   type        = string
# }
# variable "vm_network_interface_id" {
#   description = "The network interface ID of the VM"
#   type        = string
# }
# variable "vm_nsg_name" {
#   description = "The name of the network security group for the VM"
#   type        = string
# }
# variable "vm_os_disk_id" {
#   description = "The OS disk ID of the VM"
#   type        = string
# }
# variable "vm_os_disk_size_gb" {
#   description = "The size of the OS disk in GB"
#   type        = number
# }
# variable "vm_os_disk_type" {
#   description = "The type of the OS disk"
#   type        = string
# }
# variable "vm_os_disk_caching" {
#   description = "The caching type for the OS disk"
#   type        = string
# }
# variable "vm_os_type" {
#   description = "The OS type of the VM"
#   type        = string
# }
# variable "vm_admin_ssh_key" {
#   description = "The SSH public key for the VM admin user"
#   type        = string
# }
# variable "vm_admin_ssh_key_path" {
#   description = "The path to the SSH public key file"
#   type        = string
# }
# variable "vm_admin_ssh_key_name" {
#   description = "The name of the SSH public key"
#   type        = string
# }
# variable "vm_admin_ssh_key_fingerprint" {
#   description = "The fingerprint of the SSH public key"
#   type        = string
# }
variable "app_service_name" {
  description = "The name of the App Service"
  type        = string
}
variable "app_service_plan_sku_name" {
  description = "The SKU name of the App Service plan"
  type        = string
}
variable "app_service_plan_sku_tier" {
  description = "The SKU tier of the App Service plan"
  type        = string
}
variable "web_app_name" {
  description = "The name of the Web App"
  type        = string

}
variable "admin_web_app_name" {
  description = "The name of the admin Web App"
  type        = string

}
variable "function_app_name" {
  description = "The name of the Function App"
  type        = string
}

variable "host_os" {
  type    = string
  default = "linux"
}

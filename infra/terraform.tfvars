#################################################################################
### Terraform Variables for Multi-Agent Ecosystem
#################################################################################
tenant_id       = "922fd3f2-2199-4d31-b069-9733c4a14c63"
subscription_id = "7060853a-10fc-46c8-b90c-5bfe6e92e62f"

resource_group_name = "multi-agent-ecosystem-rg"
location            = "East US"
environment         = "QA"
tags = {
  environment = "dev"
  project     = "multi-agent-ecosystem"
}

#################################################################################
# Service Principal Configuration
#################################################################################
client_id     = "your-client-id"
client_secret = "your-client-secret"

#################################################################################
# Storage Account Configuration
#################################################################################
storage_account_name   = "cdgfrgmultiagentstorage"
storage_container_name = "chunked"
storage_blob_name      = "chunked-data"

#################################################################################
# vNET and Subnet
##################################################################################

# Logic for deploying vnet and subnet
deploy_vnet        = true
vnet_name          = "anvil-vnet"
vnet_address_space = "10.0.0.0/16"

subnet_deployment = [{
  name              = "sledgehammer-subnet"
  address           = "10.0.1.0/24",
  enable_delegation = false,
  }, {
  name              = "webfarm-subnet"
  address           = "10.0.2.0/24",
  enable_delegation = true,
}]

################################################################################
# Azure AI Search
################################################################################

search_service_name = "multiagentsearch-codingforge"
search_service_sku  = "Standard"


################################################################################
# OpenAI Deployments
################################################################################
openai_deployments = [{
  name = "gpt-35-turbo"
  model = {
    name    = "gpt-35-turbo"
    version = "latest"
  }
  scale = {
    type     = "Standard"
    capacity = 1
  }
  rai_policy_name = "gpt-35-turbo-rai-policy"
  },
  {
    name = "gpt-4"
    model = {
      name    = "gpt-4"
      version = "latest"
    }
    scale = {
      type     = "Standard"
      capacity = 1
    }
    rai_policy_name = "gpt-4-rai-policy"
  },
  {
    name = "gpt-4o"
    model = {
      name    = "gpt-4o"
      version = "latest"
    }
    scale = {
      type     = "Standard"
      capacity = 1
    }
    rai_policy_name = "gpt-4o-rai-policy"
  },
  {
    name = "text-embeddings-ada-002"
    model = {
      name    = "text-embeddings-ada-002"
      version = "latest"
    }
    scale = {
      type     = "Standard"
      capacity = 1
    }
    rai_policy_name = "text-embeddings-ada-002-rai-policy"
}]

################################################################################
# app service configuration
################################################################################

app_service_name          = "multi-agent-app-service"
app_service_plan_sku_name = "S1"
app_service_plan_sku_tier = "Standard"


################################################################################
# Web and Function App Configuration
################################################################################
web_app_name       = "multi-agent-web-app"
admin_web_app_name = "multi-agent-admin-web-app"
function_app_name  = "multi-agent-function-app"


################################################################################
# VM Configuration
################################################################################
# vm_name                 = "multi-agent-vm"
# vm_size                 = "Standard_DS2_v2"
# vm_admin_username       = "azureuser"
# vm_admin_password       = "P@s$w0rD1234!"
# vm_image_publisher      = "Canonical"
# vm_image_offer          = "UbuntuServer"
# vm_image_sku            = "24.04-LTS"
# vm_image_version        = "latest"
# vm_os_disk_size_gb      = 30
# vm_os_disk_type         = "StandardSSD_LRS"
# vm_os_disk_caching      = "ReadWrite"
# vm_network_interface_id = azurerm_network_interface.vm_nic.id
# vm_public_ip            = "108.8.25.47"
# vm_private_ip           = "10.0.1.24"
# vm_nsg_name             = "multi-agent-nsg"
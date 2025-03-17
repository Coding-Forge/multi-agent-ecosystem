resource_group_name  = "multi-agent-ecosystem-rg"
location             = "East US"
deploy_vnet          = true
tenant_id            = "922fd3f2-2199-4d31-b069-9733c4a14c63"
subscription_id      = "7060853a-10fc-46c8-b90c-5bfe6e92e62f"
client_id            = "your-client-id"
client_secret        = "your-client-secret"
environment          = "dev"
vnet_address_space   = "10.0.0.0/16"
subnet_name          = "sledgehammer-subnet"
subnet_address_space = "10.0.1.0/24"
tags = {
  environment = "dev"
  project     = "multi-agent-ecosystem"
}

vnet_name = "anvil-vnet"


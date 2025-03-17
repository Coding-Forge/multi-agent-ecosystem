terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

module "vnet" {
  source              = "./modules/azurerm/resource/vnet"
  vnet_name           = var.vnet_name
  deploy_vnet         = var.deploy_vnet
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  vnet_address_space  = var.vnet_address_space
  environment         = var.environment
  subnet_name         = var.subnet_name
  subnet_prefix       = var.subnet_prefix
  tags                = var.tags
}

module "subnet" {
  source               = "./modules/azurerm/resource/subnet"
  vnet_name            = var.vnet_name
  subnet_name          = var.subnet_name
  deploy_vnet          = var.deploy_vnet
  resource_group_name  = azurerm_resource_group.rg.name
  location             = azurerm_resource_group.rg.location
  subnet_address_space = var.subnet_address_space
  environment          = var.environment
}



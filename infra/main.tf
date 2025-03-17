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

resource "azurerm_storage_account" "storage_account" {
    name                     = "${var.environment}_storageaccount"
    resource_group_name      = azurerm_resource_group.rg.name
    location                 = azurerm_resource_group.rg.location
    account_tier             = "Standard"
    account_replication_type = "LRS"
    tags                     = merge(
        var.tags,
        {
        environment = var.environment
        }
    )
}

resource "azurerm_storage_container" "storage_container" {
    name                  = "${var.environment}-container"
    container_access_type = "private"
}

resource "azurerm_storage_blob" "storage_blob" {
    name                   = "${var.environment}-blob"
    storage_account_name   = azurerm_storage_account.storage_account.name
    storage_container_name = azurerm_storage_container.storage_container.name
    type                   = "Block"
}

# Create Cognitive Services for Form Recognizer, OpenAI, and other services
resource "azurerm_cognitive_account" "form_recognizer_account" {
    name                = "${var.environment}-form-rec-account"
    resource_group_name = azurerm_resource_group.rg.name
    location            = azurerm_resource_group.rg.location
    sku_name            = "S1"
    kind                = "FormRecognizer"
    public_network_access_enabled = var.deploy_vnet ? false : true
    custom_subdomain_name = "${var.environment}-form-rec-account"

    tags                = merge(
        var.tags,
        {
        environment = var.environment
        }
    )

    identity {
        type = "SystemAssigned"
    }

    network_acls {
        default_action = "Allow"
    }

    lifecycle {
        ignore_changes = [
            # public_network_access_enabled,
            # network_acls[0].default_action,
            tags,
        ]
    }
}

resource "azurerm_openai_resource" "azure_openai_resource" {
    name                = "${var.environment}-azopenai-resource"
    resource_group_name = azurerm_resource_group.rg.name
    location            = azurerm_resource_group.rg.location
    sku_name            = "S1"
    kind                = "CognitiveServices"

    tags                = merge(
        var.tags,
        {
        environment = var.environment
        }
    )

    identity {
        type = "SystemAssigned"
    }

    network_acls {
        default_action = "Allow"
    }

    lifecycle {
        ignore_changes = [
            # public_network_access_enabled,
            # network_acls[0].default_action,
            tags,
        ]
    }
}

resource "azurerm_openai_deployment" "openai_deployment" {
    for_each            = {for deployment in var.openai_deployments: deployment.name => deployment}
    name                = each.key
    openai_resource_id  = azurerm_openai_resource.azure_openai_resource.id

    model {
        format = "OpenAI"
        name  = each.value.model.name
        version = each.value.model.version
    }
    scale {
        type = each.value.scale.type
        capacity = each.value.scale.capacity
    }
    rai_policy_name = each.value.rai_policy_name

    tags                = merge(
        var.tags,
        {
        environment = var.environment
        }
    )

    lifecycle {
        ignore_changes = [
            tags,
        ]
    }
}

resource "azurerm_cognitive_account" "content_safety_account" {
    name                = "${var.environment}-content-safety-account"
    resource_group_name = azurerm_resource_group.rg.name
    location            = azurerm_resource_group.rg.location
    sku_name            = "S1"
    kind                = "ContentSafety"
    public_network_access_enabled = var.deploy_vnet ? false : true
    custom_subdomain_name = "${var.environment}-content-safety-account"

    tags                = merge(
        var.tags,
        {
        environment = var.environment
        }
    )

    identity {
        type = "SystemAssigned"
    }

    network_acls {
        default_action = "Allow"
    }

    lifecycle {
        ignore_changes = [
            # public_network_access_enabled,
            # network_acls[0].default_action,
            tags,
        ]
    }

}
resource "azurerm_cognitive_account" "speech_account" {
    name                = "${var.environment}-speech-account"
    resource_group_name = azurerm_resource_group.rg.name
    location            = azurerm_resource_group.rg.location
    sku_name            = "S1"
    kind                = "SpeechServices"
    public_network_access_enabled = var.deploy_vnet ? false : true
    custom_subdomain_name = "${var.environment}-speech-account"

    tags                = merge(
        var.tags,
        {
        environment = var.environment
        }
    )

    identity {
        type = "SystemAssigned"
    }

    network_acls {
        default_action = "Allow"
    }

    lifecycle {
        ignore_changes = [
            # public_network_access_enabled,
            # network_acls[0].default_action,
            tags,
        ]
    }
}

resource "azurerm_search_service" "ai_search_service" {
    name                = "${var.environment}-search-service"
    resource_group_name = azurerm_resource_group.rg.name
    location            = azurerm_resource_group.rg.location
    sku = "S1"
    public_network_access_enabled = var.deploy_vnet ? false : true

    tags                = merge(
        var.tags,
        {
        environment = var.environment
        }
    )

    identity {
        type = "SystemAssigned"
    }

    timeouts {
        create = "60m"
        update = "60m"
        read = "10m"
    }

    lifecycle {
        ignore_changes = [
            # public_network_access_enabled,
            # network_acls[0].default_action,
            tags,
        ]
    }   
}

resource "azurerm_key_vault" "key_vault" {
    name                = "${var.environment}-keyvault"
    resource_group_name = azurerm_resource_group.rg.name
    location            = azurerm_resource_group.rg.location
    sku_name            = "standard"
    tenant_id           = var.tenant_id

    tags                = merge(
        var.tags,
        {
        environment = var.environment
        }
    )

    lifecycle {
        ignore_changes = [
            # public_network_access_enabled,
            # network_acls[0].default_action,
            tags,
        ]
    }
}

resource "azurerm_key_vault_secret" "storage_account_secret" {
    name = "${var.environment}-storage-account-secret"
    value = azurerm_storage_account.storage_account.primary_connection_string
    key_vault_id = azurerm_key_vault.key_vault.id
}
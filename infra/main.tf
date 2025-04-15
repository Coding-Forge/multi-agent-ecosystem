terraform {
  backend "azurerm" {
    use_cli              = true
    use_azuread_auth     = true
    resource_group_name  = "templates"
    storage_account_name = "tfstate4codingforge"
    container_name       = "tfstate"
    key                  = "dev.multiagent.tfstate"
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.26.0"
      # version = "~> 4.0"
    }
  }

  required_version = "~> 1.11.0"
}

resource "random_integer" "random_0_to_5" {
  min = 0
  max = 8
}

locals {
  # suffix = "-${substr(md5(var.environment), random_integer.random_0_to_5.result, 4)}"
  suffix = "-${substr(md5(var.environment), 5, 4)}"
}

provider "azurerm" {
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    "azd-env-name" = var.environment
    "solution"     = "RAG"
    "environment"  = var.environment
  }
}

module "vnet" {
  source              = "./modules/azurerm/resource/vnet"
  vnet_name           = var.vnet_name
  deploy_vnet         = var.deploy_vnet
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  vnet_address_space  = var.vnet_address_space
  environment         = var.environment
  tags                = var.tags
}

module "subnet" {
  for_each             = { for subnet in var.subnet_deployment : subnet.name => subnet }
  source               = "./modules/azurerm/resource/subnet"
  vnet_name            = module.vnet.vnet_name
  subnet_name          = each.value.name
  deploy_vnet          = var.deploy_vnet
  resource_group_name  = azurerm_resource_group.rg.name
  location             = azurerm_resource_group.rg.location
  subnet_address_space = each.value.address
  environment          = var.environment
  enable_delegation    = each.value.enable_delegation != null ? each.value.enable_delegation : false
}

module "storage_account" {
  source                        = "./modules/azurerm/resource/storage"
  storage_account_name          = var.storage_account_name
  resource_group_name           = azurerm_resource_group.rg.name
  location                      = azurerm_resource_group.rg.location
  environment                   = var.environment
  tags                          = var.tags
  public_network_access_enabled = var.deploy_vnet ? false : true
  storage_container_name        = var.storage_container_name
  storage_blob_name             = var.storage_blob_name
}

module "storage_account_pe" {
  #   count                           = var.deploy_vnet ? 1 : 0
  source                          = "./modules/azurerm/resource/privateendpoints"
  private_endpoint_name           = "${var.environment}-pe-storage-account"
  location                        = azurerm_resource_group.rg.location
  resource_group_name             = azurerm_resource_group.rg.name
  private_service_connection_name = "storage-account-connection"
  private_connection_resource_id  = module.storage_account.storage_account_id
  subresource_names               = ["blob"]
  environment                     = var.environment
  subnet_id                       = module.subnet[var.subnet_deployment[0].name].subnet_id
  deploy_private_endpoint         = var.deploy_vnet ? true : false
}

resource "azurerm_storage_queue" "storage_queue" {
  name                 = "${var.environment}-storage-queue"
  storage_account_name = module.storage_account.storage_account_name

  metadata = {
    environment = var.environment
  }
}

resource "azurerm_eventgrid_system_topic" "blob_topic" {
  name                   = "my-blob-topic"
  resource_group_name    = azurerm_resource_group.rg.name
  location               = azurerm_resource_group.rg.location
  topic_type             = "Microsoft.Storage.StorageAccounts"
  source_arm_resource_id = module.storage_account.storage_account_id
}

resource "azurerm_eventgrid_system_topic_event_subscription" "function_subscription" {
  name                = "blob-in-trigger"
  system_topic        = azurerm_eventgrid_system_topic.blob_topic.name
  resource_group_name = azurerm_resource_group.rg.name

  storage_queue_endpoint {
    queue_message_time_to_live_in_seconds = -1
    storage_account_id                    = module.storage_account.storage_account_id
    queue_name                            = azurerm_storage_queue.storage_queue.name
  }

  subject_filter {
    subject_begins_with = "/blobServices/default/containers/${module.storage_account.storage_container_name}/blobs/"
  }

  retry_policy {
    max_delivery_attempts = 30
    event_time_to_live    = 1440
  }
  event_delivery_schema = "EventGridSchema"

  included_event_types = [
    "Microsoft.Storage.BlobCreated",
    "Microsoft.Storage.BlobDeleted"
  ]
}

# Create Cognitive Services for Form Recognizer, OpenAI, and other services
resource "azurerm_cognitive_account" "form_recognizer_account" {
  name                          = "${var.environment}-form-rec-account${local.suffix}"
  resource_group_name           = azurerm_resource_group.rg.name
  location                      = azurerm_resource_group.rg.location
  sku_name                      = "S0"
  kind                          = "FormRecognizer"
  public_network_access_enabled = var.deploy_vnet ? false : true
  custom_subdomain_name         = "${var.environment}-form-rec-account${local.suffix}"

  tags = merge(
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

module "form_recognizer_pe" {
  #   count                           = var.deploy_vnet ? 1 : 0
  source                          = "./modules/azurerm/resource/privateendpoints"
  private_endpoint_name           = "${var.environment}-pe-form-recognizer-account"
  location                        = azurerm_resource_group.rg.location
  resource_group_name             = azurerm_resource_group.rg.name
  private_service_connection_name = "form-recognizer-account-connection"
  private_connection_resource_id  = azurerm_cognitive_account.form_recognizer_account.id
  subresource_names               = ["account"]
  environment                     = var.environment
  subnet_id                       = module.subnet[var.subnet_deployment[0].name].subnet_id
  deploy_private_endpoint         = var.deploy_vnet
}

resource "azurerm_cognitive_account" "azure_openai_resource" {
  name                          = "${var.environment}-azopenai-resource${local.suffix}"
  resource_group_name           = azurerm_resource_group.rg.name
  location                      = azurerm_resource_group.rg.location
  sku_name                      = "S0"
  kind                          = "OpenAI"
  public_network_access_enabled = var.deploy_vnet ? false : true
  custom_subdomain_name         = "${var.environment}-azopenai-resource${local.suffix}"

  tags = merge(
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

module "azure_openai_pe" {
  count                           = var.deploy_vnet ? 1 : 0
  source                          = "./modules/azurerm/resource/privateendpoints"
  private_endpoint_name           = "${var.environment}-pe-open-ai-resource"
  location                        = azurerm_resource_group.rg.location
  resource_group_name             = azurerm_resource_group.rg.name
  private_service_connection_name = "open-ai-resource-connection"
  private_connection_resource_id  = azurerm_cognitive_account.azure_openai_resource.id
  subresource_names               = ["account"]
  environment                     = var.environment
  subnet_id                       = module.subnet[var.subnet_deployment[0].name].subnet_id
  deploy_private_endpoint         = var.deploy_vnet
}

resource "azurerm_cognitive_account" "content_safety_account" {
  name                          = "${var.environment}-content-safety-account${local.suffix}"
  resource_group_name           = azurerm_resource_group.rg.name
  location                      = azurerm_resource_group.rg.location
  sku_name                      = "S0"
  kind                          = "ContentSafety"
  public_network_access_enabled = var.deploy_vnet ? false : true
  custom_subdomain_name         = "${var.environment}-content-safety-account${local.suffix}"

  tags = merge(
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

module "content_safety_pe" {
  count                           = var.deploy_vnet ? 1 : 0
  source                          = "./modules/azurerm/resource/privateendpoints"
  private_endpoint_name           = "${var.environment}-pe-content-safety-account"
  location                        = azurerm_resource_group.rg.location
  resource_group_name             = azurerm_resource_group.rg.name
  private_service_connection_name = "content-safety-account-connection"
  private_connection_resource_id  = azurerm_cognitive_account.content_safety_account.id
  subresource_names               = ["account"]
  environment                     = var.environment
  subnet_id                       = module.subnet[var.subnet_deployment[0].name].subnet_id
  deploy_private_endpoint         = var.deploy_vnet
}

resource "azurerm_search_service" "ai_search_service" {
  name                          = var.search_service_name
  resource_group_name           = azurerm_resource_group.rg.name
  location                      = azurerm_resource_group.rg.location
  sku                           = "standard"
  public_network_access_enabled = var.deploy_vnet ? false : true

  tags = merge(
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
    read   = "10m"
  }

  lifecycle {
    ignore_changes = [
      # public_network_access_enabled,
      # network_acls[0].default_action,
      tags,
    ]
  }
}

module "ai_search_service_pe" {
  count                           = var.deploy_vnet ? 1 : 0
  source                          = "./modules/azurerm/resource/privateendpoints"
  private_endpoint_name           = "${var.environment}-pe-search-service"
  location                        = azurerm_resource_group.rg.location
  resource_group_name             = azurerm_resource_group.rg.name
  private_service_connection_name = "search-service-connection"
  private_connection_resource_id  = azurerm_search_service.ai_search_service.id
  subresource_names               = ["searchService"]
  environment                     = var.environment
  subnet_id                       = module.subnet[var.subnet_deployment[0].name].subnet_id
  deploy_private_endpoint         = var.deploy_vnet
}

resource "azurerm_service_plan" "service_plan" {
  name                = var.app_service_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku_name            = var.app_service_plan_sku_name
  os_type             = "Linux"

  tags = merge(
    var.tags,
    {
      environment  = var.environment
      azd-env-name = var.environment
      solution     = "RAG"
    }
  )

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

resource "azurerm_linux_web_app" "web_app" {
  name                                           = var.web_app_name
  resource_group_name                            = azurerm_resource_group.rg.name
  location                                       = azurerm_resource_group.rg.location
  service_plan_id                                = azurerm_service_plan.service_plan.id
  ftp_publish_basic_authentication_enabled       = false
  https_only                                     = true
  public_network_access_enabled                  = var.deploy_vnet ? false : true
  virtual_network_subnet_id                      = module.subnet[var.subnet_deployment[1].name].subnet_id
  webdeploy_publish_basic_authentication_enabled = false
  app_settings = {
    "AZURE_BLOB_STORAGE_CONNECTION_STRING" = module.storage_account.storage_connection_string
    "AZURE_BLOB_STORAGE_CONTAINER_NAME"    = module.storage_account.storage_container_name
    "AZURE_BLOB_STORAGE_ACCOUNT_NAME"      = module.storage_account.storage_account_name
    "WEBSITE_RUN_FROM_PACKAGE"             = "1"
    "WEBSITE_NODE_DEFAULT_VERSION"         = "18"
    "WEBSITE_WEBDEPLOY_USE_SCM"            = "false"
  }

  site_config {
    always_on                         = true
    http2_enabled                     = true
    ip_restriction_default_action     = "Allow"
    scm_ip_restriction_default_action = "Allow"
    use_32_bit_worker                 = false
    vnet_route_all_enabled            = true
    app_command_line                  = "npm start"
    cors {
      allowed_origins     = ["https://portal.azure.com"]
      support_credentials = true
    }
    application_stack {
      python_version = "3.12"
    }
  }
  identity {
    type = "SystemAssigned"
  }
  tags = merge(
    var.tags,
    {
      environment      = var.environment
      azd-env-name     = var.environment
      azd-service-name = "web"
      solution         = "RAG"
    }
  )
  lifecycle {
    ignore_changes = [
      app_settings,
      tags,
    ]
  }
  logs {
    detailed_error_messages = true
    failed_request_tracing  = true
    application_logs {
      file_system_level = "Verbose"
    }
    http_logs {
      file_system {
        retention_in_days = 1
        retention_in_mb   = 35
      }
    }
  }
}

module "web_app_pe" {
  count                           = var.deploy_vnet ? 1 : 0
  source                          = "./modules/azurerm/resource/privateendpoints"
  private_endpoint_name           = "${var.environment}-pe-web-app"
  location                        = azurerm_resource_group.rg.location
  resource_group_name             = azurerm_resource_group.rg.name
  private_service_connection_name = "web-app-connection"
  private_connection_resource_id  = azurerm_linux_web_app.web_app.id
  subresource_names               = ["sites"]
  environment                     = var.environment
  subnet_id                       = module.subnet[var.subnet_deployment[0].name].subnet_id
  deploy_private_endpoint         = var.deploy_vnet

}

resource "azurerm_linux_web_app" "admin_web_app" {
  name                                     = var.admin_web_app_name
  resource_group_name                      = azurerm_resource_group.rg.name
  location                                 = azurerm_resource_group.rg.location
  service_plan_id                          = azurerm_service_plan.service_plan.id
  ftp_publish_basic_authentication_enabled = false
  https_only                               = true
  public_network_access_enabled            = var.deploy_vnet ? false : true
  virtual_network_subnet_id                = module.subnet[var.subnet_deployment[1].name].subnet_id
  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE"     = "1"
    "WEBSITE_NODE_DEFAULT_VERSION" = "18"
    "WEBSITE_WEBDEPLOY_USE_SCM"    = "false"
  }
  site_config {
    always_on                         = true
    http2_enabled                     = true
    ip_restriction_default_action     = "Allow"
    scm_ip_restriction_default_action = "Allow"
    use_32_bit_worker                 = false
    vnet_route_all_enabled            = true
    app_command_line                  = "npm start"
    cors {
      allowed_origins     = ["https://portal.azure.com"]
      support_credentials = true
    }
    application_stack {
      python_version = "3.12"
    }
  }
  identity {
    type = "SystemAssigned"
  }
  logs {
    detailed_error_messages = true
    failed_request_tracing  = true
    application_logs {
      file_system_level = "Verbose"
    }
    http_logs {
      file_system {
        retention_in_days = 1
        retention_in_mb   = 35
      }
    }
  }
  tags = merge(
    var.tags,
    {
      environment      = var.environment
      azd-env-name     = var.environment
      azd-service-name = "adminweb"
      solution         = "RAG"
    }
  )
  lifecycle {
    ignore_changes = [
      app_settings,
      tags,
    ]
  }
}

module "admin_web_app_pe" {
  count                           = var.deploy_vnet ? 1 : 0
  source                          = "./modules/azurerm/resource/privateendpoints"
  private_endpoint_name           = "${var.environment}-pe-admin-web-app"
  location                        = azurerm_resource_group.rg.location
  resource_group_name             = azurerm_resource_group.rg.name
  private_service_connection_name = "admin-web-app-connection"
  private_connection_resource_id  = azurerm_linux_web_app.admin_web_app.id
  subresource_names               = ["sites"]
  environment                     = var.environment
  subnet_id                       = module.subnet[var.subnet_deployment[0].name].subnet_id
  deploy_private_endpoint         = var.deploy_vnet
}

resource "azurerm_linux_function_app" "function_app" {
  name                 = var.function_app_name
  resource_group_name  = azurerm_resource_group.rg.name
  location             = azurerm_resource_group.rg.location
  service_plan_id      = azurerm_service_plan.service_plan.id
  storage_account_name = module.storage_account.storage_account_name
  # storage_account_access_key                     = module.storage_account.primary_access_key
  functions_extension_version                    = "~4"
  https_only                                     = true
  public_network_access_enabled                  = var.deploy_vnet ? false : true
  virtual_network_subnet_id                      = module.subnet[var.subnet_deployment[1].name].subnet_id
  ftp_publish_basic_authentication_enabled       = false
  webdeploy_publish_basic_authentication_enabled = false
  enabled                                        = true

  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME"    = "python"
    "AzureWebJobsStorage"         = module.storage_account.storage_connection_string
    "FUNCTIONS_EXTENSION_VERSION" = "~4"
    "FUNCTIONS_WORKER_RUNTIME"    = "python"
    "AzureWebJobsDashboard"       = module.storage_account.storage_connection_string
  }
  site_config {
    always_on                         = true
    http2_enabled                     = true
    ip_restriction_default_action     = "Allow"
    scm_ip_restriction_default_action = "Allow"
    use_32_bit_worker                 = false
    vnet_route_all_enabled            = true
    app_command_line                  = "npm start"
    cors {
      allowed_origins     = ["https://portal.azure.com"]
      support_credentials = true
    }
    application_stack {
      python_version = "3.12"
    }
  }

  identity {
    type = "SystemAssigned"
  }

  tags = merge(
    var.tags,
    {
      environment      = var.environment
      azd-env-name     = var.environment
      azd-service-name = "function"
      solution         = "RAG"
    }
  )

  lifecycle {
    ignore_changes = [
      app_settings,
      tags,
    ]
  }
}

module "function_app_pe" {
  count                           = var.deploy_vnet ? 1 : 0
  source                          = "./modules/azurerm/resource/privateendpoints"
  private_endpoint_name           = "${var.environment}-pe-function-app"
  location                        = azurerm_resource_group.rg.location
  resource_group_name             = azurerm_resource_group.rg.name
  private_service_connection_name = "function-app-connection"
  private_connection_resource_id  = azurerm_linux_function_app.function_app.id
  subresource_names               = ["sites"]
  environment                     = var.environment
  subnet_id                       = module.subnet[var.subnet_deployment[0].name].subnet_id
  deploy_private_endpoint         = var.deploy_vnet
}

resource "azurerm_public_ip" "pip" {
  name                = "${azurerm_resource_group.rg.name}-pip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"

  tags = {
    environment = "dev"
  }
}

resource "azurerm_network_interface" "nic" {
  name                = "${azurerm_resource_group.rg.name}-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "${azurerm_resource_group.rg.name}-ipconfig"
    subnet_id                     = module.subnet[var.subnet_deployment[0].name].subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }

  tags = {
    environment = "dev"
  }
}

# resource "azurerm_windows_virtual_machine" "devbox-vm" {
#   name                = "win-devbox-vm"
#   resource_group_name = azurerm_resource_group.rg.name
#   location            = azurerm_resource_group.rg.location
#   size                = "Standard_DS2_v2"
#   admin_username      = "adminuser"
#   network_interface_ids = [azurerm_network_interface.nic.id]

#   custom_data = filebase64("./devbox/custom_data.tpl")

#   admin_password = "P@ssw0rd1234!"

#   os_disk {
#     caching              = "ReadWrite"
#     storage_account_type = "Standard_LRS"
#   }

#   source_image_reference {
#     publisher = "MicrosoftWindowsServer"
#     offer     = "WindowsServer"
#     sku       = "2022-Datacenter"
#     version   = "latest"
#   }

#   provisioner "local-exec" {
#     command = templatefile("./devbox/${var.host_os}-ssh-scripts.tpl", {
#       hostname     = self.public_ip_address,
#       user         = "adminuser",
#       identityfile = "~/.ssh/devbox"
#     })
#     interpreter = var.host_os == "linux" ? ["bash", "-c"] : ["Powershell", "-Command"]
#   }

#   tags = {
#     environment = "dev"
#   }  
# }

resource "azurerm_linux_virtual_machine" "devbox-vm" {
  name                  = "${azurerm_resource_group.rg.name}-vm"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  size                  = "Standard_DS2_v2"
  admin_username        = "adminuser"
  network_interface_ids = [azurerm_network_interface.nic.id]

  custom_data = filebase64("./devbox/custom_data.tpl")

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/devbox.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  provisioner "local-exec" {
    command = templatefile("./devbox/${var.host_os}-ssh-scripts.tpl", {
      hostname     = self.public_ip_address,
      user         = "adminuser",
      identityfile = "~/.ssh/devbox"
    })
    interpreter = var.host_os == "linux" ? ["bash", "-c"] : ["Powershell", "-Command"]
  }

  tags = {
    environment = "dev"
  }
}

data "azurerm_public_ip" "chat-ip-data" {
  name                = azurerm_public_ip.pip.name
  resource_group_name = azurerm_resource_group.rg.name
}

output "public_ip_address" {
  value = "${azurerm_linux_virtual_machine.devbox-vm.name}: ${data.azurerm_public_ip.chat-ip-data.ip_address}"
  # value = "${azurerm_windows_virtual_machine.devbox-vm.name}: ${data.azurerm_public_ip.chat-ip-data.ip_address}"
}

# resource "azurerm_cognitive_account" "speech_account" {
#   name                          = "${var.environment}-speech-account"
#   resource_group_name           = azurerm_resource_group.rg.name
#   location                      = azurerm_resource_group.rg.location
#   sku_name                      = "S0"
#   kind                          = "SpeechServices"
#   public_network_access_enabled = var.deploy_vnet ? false : true
#   custom_subdomain_name         = "${var.environment}-speech-account"

#   tags = merge(
#     var.tags,
#     {
#       environment = var.environment
#     }
#   )

#   identity {
#     type = "SystemAssigned"
#   }

#   network_acls {
#     default_action = "Allow"
#   }

#   lifecycle {
#     ignore_changes = [
#       # public_network_access_enabled,
#       # network_acls[0].default_action,
#       tags,
#     ]
#   }
# }

# # module "speech_pe" {
# #   count                           = var.deploy_vnet ? 1 : 0
# #   source                          = "./modules/azurerm/resource/privateendpoints"
# #   private_endpoint_name           = "${var.environment}-pe-speech-account"
# #   location                        = azurerm_resource_group.rg.location
# #   resource_group_name             = azurerm_resource_group.rg.name
# #   private_service_connection_name = "speech-account-connection"
# #   private_connection_resource_id  = azurerm_cognitive_account.speech_account.id
# #   subresource_names               = ["SpeechServices"]
# #   environment                     = var.environment
# # #   subnet_id                       = module.subnet[var.subnet_deployment[1].name].subnet_id
# # }


# resource "azurerm_application_insights" "app_insights" {
#   name                = "${var.environment}-app-insights"
#   resource_group_name = azurerm_resource_group.rg.name
#   location            = azurerm_resource_group.rg.location
#   application_type    = "web"

#   tags = merge(
#     var.tags,
#     {
#       environment  = var.environment
#       azd-env-name = var.environment
#       solution     = "RAG"
#     }
#   )

#   lifecycle {
#     ignore_changes = [
#       tags,
#     ]
#   }
# }

# # resource "azurerm_key_vault" "key_vault" {
# #   name                = "${var.environment}-keyvault"
# #   resource_group_name = azurerm_resource_group.rg.name
# #   location            = azurerm_resource_group.rg.location
# #   sku_name            = "standard"
# #   tenant_id           = var.tenant_id

# #   tags = merge(
# #     var.tags,
# #     {
# #       environment = var.environment
# #     }
# #   )

# #   lifecycle {
# #     ignore_changes = [
# #       # public_network_access_enabled,
# #       # network_acls[0].default_action,
# #       tags,
# #     ]
# #   }
# # }

# # resource "azurerm_key_vault_secret" "storage_account_keysecret" {
# #   name         = "${var.environment}-storage-account-secret"
# #   value        = azurerm_storage_account.storage_account.storage_account_primary_access_key
# #   key_vault_id = azurerm_key_vault.key_vault.id
# # }

# # resource "azurerm_key_vault_secret" "openai_keysecret" {
# #   name         = "${var.environment}-open-ai-keysecret"
# #   value        = azurerm_openai_resource.azure_openai_resource.primary_access_key
# #   key_vault_id = azurerm_key_vault.key_vault.id
# # }

# # resource "azurerm_network_security_group" "vm_nsg" {
# #   name                = "my-vm-nsg"
# #   resource_group_name = "<YOUR_RG_NAME>"
# #   location            = "<YOUR_LOCATION>"
# # }

# # resource "azurerm_network_security_rule" "allow_rdp" {
# #   name                        = "allow-rdp"
# #   resource_group_name         = azurerm_resource_group.rg.name
# #   priority                    = 100
# #   direction                   = "Inbound"
# #   access                      = "Allow"
# #   protocol                    = "Tcp"
# #   source_port_ranges          = ["*"]
# #   destination_port_ranges     = ["3389"]
# #   source_address_prefixes     = ["108.196.164.24"]
# #   destination_address_prefix  = "*"
# #   network_security_group_name = azurerm_network_security_group.vm_nsg.name
# # }
# Configure the provider

provider "azurerm" {
    version         = "=2.0.0"
    subscription_id = var.azure_subscription_id
    client_id       = var.service_principal_client_id
    client_secret   = var.service_principal_client_secret
    tenant_id       = var.azure_ad_tenant_id 
    skip_provider_registration = true
    features{}
}

# Create a new resource group
resource "azurerm_resource_group" "rg" {
    name     = "${var.base_name}rg"
    location = var.location
}

resource "azurerm_storage_account" "az_backend" {
  name                     = "${var.base_name}stg"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "standard"
  account_replication_type = "RAGRS"
  account_kind             = "StorageV2"
  tags = {
    env = "prod"
  }
}

resource "azurerm_storage_container" "web" {
  name                  = "web"
  storage_account_name  = azurerm_storage_account.az_backend.name
  container_access_type = "blob"
  lifecycle {
    prevent_destroy = false
  }
}

#Azure Functions setup
resource "azurerm_application_insights" "app_insights" {
  name                = "${var.base_name}ai"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"
}

#add App Service Plan
resource "azurerm_app_service_plan" "app_service_plan" {
  name                = "${var.base_name}appserv"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  kind                = "linux"
  reserved            = true
  sku {
    tier = "Basic"
    size = "B1"
  }
}

resource "azurerm_application_insights" "ai" {
  name                = "${var.base_name}ai"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"
}

#add AZ Functions
resource "azurerm_function_app" "apis" {
  name                      = "${var.base_name}func"
  location                  = azurerm_resource_group.rg.location
  resource_group_name       = azurerm_resource_group.rg.name
  app_service_plan_id       = azurerm_app_service_plan.app_service_plan.id
  storage_connection_string = azurerm_storage_account.az_backend.primary_connection_string
  https_only                = false
  version                   = "~3"
  app_settings = {
    APPINSIGHTS_INSTRUMENTATIONKEY  = azurerm_application_insights.ai.instrumentation_key
    BUILD_FLAGS                     = "UseExpressBuild"
    ENABLE_ORYX_BUILD               = "true"
    FUNCTIONS_WORKER_RUNTIME        = "python"
    SCM_DO_BUILD_DURING_DEPLOYMENT  = "1"
    WEBSITE_HTTPLOGGING_RETENTION_DAYS = "7"
    WEBSITE_NODE_DEFAULT_VERSION    = "10.14.1"
    XDG_CACHE_HOME                  = "/tmp/.cache"

    USE_SAAS_MOCK_API               = "false"
    APP_SERVICE_URL                 = "https://${var.base_name}func.azurewebsites.net"
    AAD_APP_CLIENT_ID               = var.aad_app_client_id
    AAD_APP_CLIENT_PASSWORD         = var.aad_app_client_password
    AAD_TENANT_ID                   = var.azure_ad_tenant_id
  }
  site_config {
    cors { 
      allowed_origins     = ["http://localhost:63342",
                             "https://${var.base_name}stg.blob.core.windows.net",
                             "https://portal.${var.domain_name}",
                             "https://${var.base_name}portal.azureedge.net"]
      support_credentials = "false"
    }
    linux_fx_version  = "DOCKER|mcr.microsoft.com/azure-functions/python:3.0-python3.8-appservice"
    always_on = true
  }
}


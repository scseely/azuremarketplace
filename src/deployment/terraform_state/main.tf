provider "azurerm" {
    version = "~>1.36"
    subscription_id = "${var.azure_subscription_id}"
    client_id       = "${var.service_principal_client_id}"
    client_secret   = "${var.service_principal_client_secret}"
    tenant_id       = "${var.azure_ad_tenant_id}"   
}

variable "base_name" {
    type    = "string"
    default = ""
}

variable "azure_ad_tenant_id" {
    type    = "string"
    default = ""
}

variable "azure_subscription_id" {
    type    = "string"
    default = ""
}

variable "service_principal_client_secret" {
    type    = "string"
    default = ""
}

variable "service_principal_client_id" {
    type    = "string"
    default = ""
}

variable "location" {
    type    = "string"
    default = "centralus"
}

resource "azurerm_resource_group" "resource_group" {
  name = "${var.base_name}tfrg"
  location = "${var.location}"
}

resource "azurerm_storage_account" "az_backend" {
  name                     = "${var.base_name}tfstg"
  resource_group_name      = "${azurerm_resource_group.resource_group.name}"
  location                 = "${azurerm_resource_group.resource_group.location}"
  account_tier             = "standard"
  account_replication_type = "RAGRS"
  account_kind             = "StorageV2"
  tags = {
    env = "prod"
  }
  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_storage_container" "az_state_lock" {
  name                  = "azstatelock"
  storage_account_name  = "${azurerm_storage_account.az_backend.name}"
  container_access_type = "private"
  lifecycle {
    prevent_destroy = true
  }
}

output "properties"{
  value = "${azurerm_storage_account.az_backend.primary_access_key}"
}
#!/bin/bash

TERRAFORM_FILE='remote-state.tf'
rm $TERRAFORM_FILE

exec 1>>$TERRAFORM_FILE
. variables.conf

echo "terraform {"
echo "  backend \"azurerm\" {"
echo "    storage_account_name  = \"$base_name""tfstg\""
echo "    access_key            = \"$storage_access_key\""
echo "    container_name        = \"azstatelock\""
echo "    key                   = \"azure_terraform.tfstate\""
echo "  }"
echo "}"
#!/bin/bash

SOURCE_FOLDER='../portal/'
DESTINATION_FOLDER='$web/'
TERRAFORM_FILE='create-file-list.sh'
EMPTY_STRING=''
rm $TERRAFORM_FILE

counter=1
for i in $(find $SOURCE_FOLDER); do # Not recommended, will break on whitespace
    if [ -f "${i}" ] ; then
        SHORT_NAME="${i//$SOURCE_FOLDER/$EMPTY_STRING}"
        echo "resource \"azurerm_storage_blob\" \"file$counter\" {"
        echo "  name                   = \"$SHORT_NAME\""
        echo "  storage_account_name   = \"\${azurerm_storage_account.az_backend.name}\""
        echo "  storage_container_name = \"\${azurerm_storage_container.web.name}\""
        echo "  type                   = \"blob\""
        echo "  source                 = \"$i\""
        echo "}"
        echo ''
        let "counter=counter+1"
    fi
done
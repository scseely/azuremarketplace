#!/bin/bash

# Setup error handling
tempfiles=( )
cleanup() {
  rm -f "${tempfiles[@]}"
}
trap cleanup 0

error() {
  local parent_lineno="$1"
  local message="$2"
  local code="${3:-1}"
  if [[ -n "$message" ]] ; then
    echo "Error on or near line ${parent_lineno}: ${message}; exiting with status ${code}"
  else
    echo "Error on or near line ${parent_lineno}; exiting with status ${code}"
  fi
  
  echo "Logging out"
  az logout

  exit "${code}"
}
trap 'error ${LINENO}' ERR

# Load the config variables
. ../variables.conf

ACTION='apply'
if [[ $# > 0 ]]; then
  ACTION=$1
fi

terraform $ACTION -auto-approve -var="azure_ad_tenant_id=$azure_ad_tenant_id" \
                                -var="azure_subscription_id=$azure_subscription_id" \
                                -var="service_principal_client_secret=$service_principal_client_secret" \
                                -var="service_principal_client_id=$service_principal_client_id" \
                                -var="base_name=$base_name" \
                                -var="location=$resource_group_location"

# {
#  "appId": "e9cd9df5-d5ab-4b1f-b0a5-ea3d8ffbf18a",
#  "displayName": "azure-cli-2019-11-15-00-24-43",
#  "name": "http://azure-cli-2019-11-15-00-24-43",
#  "password": "c04896f3-6785-4cac-b68c-394fede2512f",
#  "tenant": "0f1a53c8-1135-457a-bcdb-d58abc87e4b7"
# }

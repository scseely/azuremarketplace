#!/bin/bash

# This script assumes that you have already uploaded a valid certificate
# to your AAD Custom Domain Names as described here: 
# https://docs.microsoft.com/azure/active-directory/fundamentals/add-custom-domain 
# The custom domain requires verification before it can be used and requires
# you to make some changes to your DNS to prove ownership.
# Domain setup is described elsewhere. Please make sure you have that
# handled before running this script. 

# Then, configure a custom domain name for your storage account.

# Then, upload certificate to a Key Vault
# Add instructions to configure custom endpoint for CDN, including 
# adding the Azure CDN auth to this solution
# Make sure to set the osadfsadfrgihe 

# Constants

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

# Load the config 
. variables.conf

ACTION='apply'
if [[ $# > 0 ]]; then
  ACTION=$1
fi

# Generate the terraform file for the static web files
if [[ $ACTION  = 'apply' ]]; then
  chmod +x create-file-list.sh
  create-file-list.sh
fi

# Generate the settings.js file
chmod +x create-settings.sh 
create-settings.sh 

# Generate the terraform remote-state file
chmod +x create-remote-state.sh
create-remote-state.sh

# Add the Azure CDN Service Principal
# az ad sp create --id 205478c0-bd83-4e1b-a9d6-db63a3e1e1c8

# Do non-interactive setup of resources

funcapp_name=$(echo $base_name)func

terraform $ACTION -auto-approve -var="azure_ad_tenant_id=$azure_ad_tenant_id" \
                                -var="azure_subscription_id=$azure_subscription_id" \
                                -var="service_principal_client_secret=$service_principal_client_secret" \
                                -var="service_principal_client_id=$service_principal_client_id" \
                                -var="base_name=$base_name" \
                                -var="domain_name=$domain_name" \
                                -var="aad_app_client_id=$aad_app_client_id" \
                                -var="location=$resource_group_location" \
                                -var="aad_app_client_password=$aad_app_client_password"

pushd ../AzureMarketplace/
if [[ $ACTION  = 'apply' ]]; then
  echo "Pausing for 30s. Function apps frequently take a bit of time to get ready to accept code."
  for i in {1..30}
    do
      echo -ne "$i.."\\r
      sleep 1s
    done
  echo "Logging in"
  az login --service-principal -u $service_principal_client_id -p $service_principal_client_secret --tenant $azure_ad_tenant_id

  func azure functionapp publish $funcapp_name

  az logout
fi
popd


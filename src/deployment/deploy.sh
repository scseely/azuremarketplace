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

resource_group=$(echo $base_name)rg

# Generate the terraform file for the static web files
if [[ $ACTION  = 'apply' ]]; then
  chmod +x create-file-list.sh
  ./create-file-list.sh

  # Force an update of all the web files, since Terraform doesn't update when the contents simply change.
  echo "Logging in to clear out storage blobs"
  az login --service-principal -u $service_principal_client_id -p $service_principal_client_secret --tenant $azure_ad_tenant_id
  az account set -s $azure_subscription_id
  connection_string=$(az storage account show-connection-string --name $(echo $base_name)stg --resource-group $resource_group --query connectionString --output tsv)
  echo "Clearing out storage blobs"
  az storage blob delete-batch -s web --connection-string "$connection_string" --pattern '*'
  az logout
fi

# Generate the settings.js file
chmod +x create-settings.sh 
./create-settings.sh 

# Generate the terraform remote-state file
#chmod +x create-remote-state.sh
#./create-remote-state.sh

# Add the Azure CDN Service Principal
# az ad sp create --id 205478c0-bd83-4e1b-a9d6-db63a3e1e1c8

# Do non-interactive setup of resources

funcapp_name=$(echo $base_name)func

terraform $ACTION -auto-approve -var="azure_ad_tenant_id=$azure_ad_tenant_id" \
                                -var="azure_subscription_id=$azure_subscription_id" \
                                -var="service_principal_client_secret=$service_principal_client_secret" \
                                -var="service_principal_client_id=$service_principal_client_guid" \
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
  az account set -s $azure_subscription_id
  func azure functionapp publish $funcapp_name --python

  az logout
fi
popd


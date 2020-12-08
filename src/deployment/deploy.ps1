function loadVariables($fileName){
    $vars = @{}
    foreach($line in Get-Content $fileName) {
        $values = $line.Split('=')
        $key = $values[0]
        $value = $values[1]
        $vars[$key] = $value
    }
    return $vars
}

function sleepForTime(){
    # Time to sleep between each notification
    $sleep_iteration = 1
    $seconds=30
    Write-Host $message
    Write-Output ( "Sleeping {0} seconds... " -f ($seconds) )
    for ($i=1 ; $i -le ([int]$seconds/$sleep_iteration) ; $i++) {
        Start-Sleep -Seconds $sleep_iteration
        Write-Progress -CurrentOperation ("Sleep {0}s" -f ($seconds)) ( " {0}s ..." -f ($i*$sleep_iteration) )
    }
    Write-Progress -CurrentOperation ("Sleep {0}s" -f ($seconds)) -Completed "Done waiting for change to take effect."
}

$variables = loadVariables('.\variables.conf')
$service_principal_client_id = $variables['service_principal_client_id']
$service_principal_client_secret = $variables['service_principal_client_secret']
$azure_ad_tenant_id = $variables['azure_ad_tenant_id']
$azure_subscription_id = $variables['azure_subscription_id']
$base_name = $variables['base_name']
$azure_ad_tenant_id = $variables['azure_ad_tenant_id']
$service_principal_client_guid = $variables['service_principal_client_guid']
$domain_name = $variables['domain_name']
$aad_app_client_id = $variables['aad_app_client_id']
$resource_group_location = $variables['resource_group_location']
$aad_app_client_password = $variables['aad_app_client_password']


$action = 'apply'

$resource_group=$base_name + "rg"

if ($action -eq 'apply'){
  ./create-file-list.ps1

  # Force an update of all the web files, since Terraform doesn't update when the contents simply change.
  Write-Host "Logging in to clear out storage blobs"
  az login --service-principal -u $service_principal_client_id -p $service_principal_client_secret --tenant $azure_ad_tenant_id
  az account set -s $azure_subscription_id
  $storageName = $base_name + "stg"
  $connection_string=(az storage account show-connection-string --name $storageName --resource-group $resource_group --query connectionString --output tsv)
  Write-Host "Clearing out storage blobs"
  az storage blob delete-batch -s web --connection-string "$connection_string" --pattern '*'
  az logout
}

./create-settings.ps1

# Generate the terraform remote-state file
#chmod +x create-remote-state.sh
#./create-remote-state.sh

# Add the Azure CDN Service Principal
# az ad sp create --id 205478c0-bd83-4e1b-a9d6-db63a3e1e1c8



terraform $ACTION -auto-approve -var="azure_ad_tenant_id=$azure_ad_tenant_id" `
                                -var="azure_subscription_id=$azure_subscription_id" `
                                -var="service_principal_client_secret=$service_principal_client_secret" `
                                -var="service_principal_client_id=$service_principal_client_guid" `
                                -var="base_name=$base_name" `
                                -var="domain_name=$domain_name" `
                                -var="aad_app_client_id=$aad_app_client_id" `
                                -var="location=$resource_group_location" `
                                -var="aad_app_client_password=$aad_app_client_password"


if ($action -eq 'apply'){
    $funcapp_name="${base_name}func"
    Push-Location ../AzureMarketplace
    sleepForTime

    Write-Host "Logging in"
    az login --service-principal -u $service_principal_client_id -p $service_principal_client_secret --tenant $azure_ad_tenant_id
    az account set -s $azure_subscription_id
    func azure functionapp publish $funcapp_name --python
    Pop-Location
}


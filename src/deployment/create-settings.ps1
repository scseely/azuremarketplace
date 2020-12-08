$SETTINGS_JS_FILE='../portal/scripts/settings.js'
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
$variables = loadVariables('.\variables.conf')
$service_principal_client_id = $variables['service_principal_client_id']
$service_principal_client_secret = $variables['service_principal_client_secret']
$azure_ad_tenant_id = $variables['azure_ad_tenant_id']
$azure_subscription_id = $variables['azure_subscription_id']
$base_name = $variables['base_name']


if (Test-Path $SETTINGS_JS_FILE){
    Remove-Item $SETTINGS_JS_FILE
}


$APPINSIGHTS_INSTALLED=(az extension list-available --query "[?name == 'application-insights'].installed" --output tsv)
Write-Host "Application Insights Installation status: $APPINSIGHTS_INSTALLED"

if ($APPINSIGHTS_INSTALLED -eq "false"){
    Write-Host "Installing app insights ext"
    az extension add --name application-insights
}

Write-Host "Logging in"

az login --service-principal -u $service_principal_client_id -p $service_principal_client_secret --tenant $azure_ad_tenant_id
az account set -s $azure_subscription_id
$RESOURCE_GROUP="${base_name}rg"
$APPID="${base_name}ai"
$APPINSIGHTS_KEY=(az monitor app-insights component show -g $RESOURCE_GROUP --query "[?applicationId == '$APPID'].instrumentationKey" --output tsv)
Write-Host "Application Insights Installation key: $APPINSIGHTS_KEY"
az logout

Set-Content -Path $SETTINGS_JS_FILE -Value "window.appBaseUrl = 'https://${base_name}func.azurewebsites.net';"
Add-Content -Path $SETTINGS_JS_FILE -Value "window.apiBaseUrl = 'https://${base_name}func.azurewebsites.net';"
Add-Content -Path $SETTINGS_JS_FILE -Value "window.authEnabled = true;"
Add-Content -Path $SETTINGS_JS_FILE -Value "window.autoLogin = true;"
Add-Content -Path $SETTINGS_JS_FILE -Value "window.debugging = false;"
Add-Content -Path $SETTINGS_JS_FILE -Value "window.requireConsent = false;"
Add-Content -Path $SETTINGS_JS_FILE -Value "window.instrumentationKey = `"$APPINSIGHTS_KEY`";"
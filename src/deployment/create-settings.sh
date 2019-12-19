#!/bin/bash

SETTINGS_JS_FILE='../portal/scripts/settings.js'
rm $SETTINGS_JS_FILE
. variables.conf

APPINSIGHTS_INSTALLED=$(az extension list-available --query "[?name == 'application-insights'].installed" --output tsv)
echo "Application Insights Installation status: $APPINSIGHTS_INSTALLED"
if [[ $APPINSIGHTS_INSTALLED != "true" ]]; then
    echo "Installing app insights ext"
    az extension add --name application-insights
fi

echo "Logging in"

az login --service-principal -u $service_principal_client_id -p $service_principal_client_secret --tenant $azure_ad_tenant_id
RESOURCE_GROUP=$(echo $base_name)rg
APPID=$(echo $base_name)ai
APPINSIGHTS_KEY=$(az monitor app-insights component show -g seelyincrg --query "[?applicationId == 'seelyincai'].instrumentationKey" --output tsv)
echo "Application Insights Installation key: $APPINSIGHTS_KEY"
az logout

exec 1>>$SETTINGS_JS_FILE


echo "window.appBaseUrl = 'https://$base_name""func.azurewebsites.net';"
echo "window.apiBaseUrl = 'https://$base_name""func.azurewebsites.net';"
echo "window.authEnabled = true;"
echo "window.autoLogin = false;"
echo "window.debugging = true;"
echo "window.requireConsent = true;"
echo "window.instrumentationKey = \"$APPINSIGHTS_KEY\"";
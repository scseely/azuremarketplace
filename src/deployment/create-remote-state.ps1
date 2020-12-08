$TERRAFORM_FILE='remote-state.tf'

if (Test-Path $TERRAFORM_FILE){
    Remove-Item $TERRAFORM_FILE
}

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
$base_name = $variables['base_name']
$storage_access_key = $variables['storage_access_key']

Set-Content -Path $SETTINGS_JS_FILE -Value "terraform {"
Add-Content -Path $SETTINGS_JS_FILE -Value  "  backend \"azurerm\" {"
Add-Content -Path $SETTINGS_JS_FILE -Value  "    storage_account_name  = \"$base_name""tfstg\""
Add-Content -Path $SETTINGS_JS_FILE -Value  "    access_key            = \"$storage_access_key\""
Add-Content -Path $SETTINGS_JS_FILE -Value  "    container_name        = \"azstatelock\""
Add-Content -Path $SETTINGS_JS_FILE -Value  "    key                   = \"azure_terraform.tfstate\""
Add-Content -Path $SETTINGS_JS_FILE -Value  "  }"
Add-Content -Path $SETTINGS_JS_FILE -Value  "}"
$SOURCE_FOLDER='../portal/'
$DESTINATION_FOLDER='$web/'
$TERRAFORM_FILE= (Get-Location).Path + '\web-file-list.tf'
$EMPTY_STRING=''

if (Test-Path $TERRAFORM_FILE){
    Remove-Item $TERRAFORM_FILE
}

function get_content_type($file_name) {
    $extension = (Get-Item $file_name).Extension
    switch ($extension){
        "aac"      { return "audio/aac" }
        "abw"      { return "application/x-abiword" }
        "arc"      { return "application/x-freearc" }
        "avi"      { return "video/x-msvideo" }
        "azw"      { return "application/vnd.amazon.ebook" }
        "bin"      { return "application/octet-stream" }
        "bmp"      { return "image/bmp" }
        "bz"       { return "application/x-bzip" }
        "bz2"      { return "application/x-bzip2" }
        "csh"      { return "application/x-csh" }
        "css"      { return "text/css" }
        "csv"      { return "text/csv" }
        "doc"      { return "application/msword" }
        "docx"     { return "application/vnd.openxmlformats-officedocument.wordprocessingml.document" }
        "eot"      { return "application/vnd.ms-fontobject" }
        "epub"     { return "application/epub+zip" }
        "gz"       { return "application/gzip" }
        "gif"      { return "image/gif" }
        "htm"      { return "text/html" }
        "html"     { return "text/html" }
        "ico"      { return "image/vnd.microsoft.icon" }
        "ics"      { return "text/calendar" }
        "jar"      { return "application/java-archive" }
        "jpeg"     { return "image/jpeg" }
        "jpg"      { return "image/jpeg" }
        "js"       { return "text/javascript" }
        "js.map"   { return "text/javascript" }
        "json"     { return "application/json" }
        "jsonld"   { return "application/ld+json" }
        "md"       { return "text/plain" }
        "mid"      { return "audio/midi audio/x-midi" }
        "midi"     { return "audio/midi audio/x-midi" }
        "mjs"      { return "text/javascript" }
        "mp3"      { return "audio/mpeg" }
        "mpeg"     { return "video/mpeg" }
        "mpkg"     { return "application/vnd.apple.installer+xml" }
        "odp"      { return "application/vnd.oasis.opendocument.presentation" }
        "ods"      { return "application/vnd.oasis.opendocument.spreadsheet" }
        "odt"      { return "application/vnd.oasis.opendocument.text" }
        "oga"      { return "audio/ogg" }
        "ogv"      { return "video/ogg" }
        "ogx"      { return "application/ogg" }
        "opus"     { return "audio/opus" }
        "otf"      { return "font/otf" }
        "png"      { return "image/png" }
        "pdf"      { return "application/pdf" }
        "php"      { return "application/php" }
        "ppt"      { return "application/vnd.ms-powerpoint" }
        "pptx"     { return "application/vnd.openxmlformats-officedocument.presentationml.presentation" }
        "rar"      { return "application/x-rar-compressed" }
        "rtf"      { return "application/rtf" }
        "sh"       { return "application/x-sh" }
        "svg"      { return "image/svg+xml" }
        "tar"      { return "application/x-tar" }
        "tif"      { return "image/tiff" }
        "tiff"     { return "image/tiff" }
        "ts"       { return "video/mp2t" }
        "ttf"      { return "font/ttf" }
        "txt"      { return "text/plain" }
        "vsd"      { return "application/vnd.visio" }
        "wav"      { return "audio/wav" }
        "weba"     { return "audio/webm" }
        "webm"     { return "video/webm" }
        "webp"     { return "image/webp" }
        "woff"     { return "font/woff" }
        "woff2"    { return "font/woff2" }
        "xhtml"    { return "application/xhtml+xml" }
        "xls"      { return "application/vnd.ms-excel" }
        "xlsx"     { return "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" }
        "xml"      { return "text/xml" }
        "xul"      { return "application/vnd.mozilla.xul+xml" }
        "zip"      { return "application/zip" }
        "7z"       { return "application/x-7z-compressed" }
        "LICENSE"  { return "text/plain" }
        default    { return "application/octet-stream" }
    }
}

$counter = 1
Set-Content -Value "" -Path $TERRAFORM_FILE
$files = Get-ChildItem $SOURCE_FOLDER -Recurse
Push-Location -Path $SOURCE_FOLDER
foreach ($file in $files){

    if (Test-Path -Path $file -PathType Container){
        continue
    }

    $contentType = get_content_type($file)
    
    $SHORT_NAME = (Resolve-Path $file -Relative).Replace("\", "/")
    $fullPath = ($file.FullName).Replace("\", "/")
    Add-Content -Value "resource `"azurerm_storage_blob`" `"file$counter`" {" -Path  $TERRAFORM_FILE
    Add-Content -Value  "  name                   = `"$SHORT_NAME`"" -Path  $TERRAFORM_FILE
    Add-Content -Value  "  storage_account_name   = azurerm_storage_account.az_backend.name" -Path  $TERRAFORM_FILE
    Add-Content -Value  "  storage_container_name = azurerm_storage_container.web.name" -Path  $TERRAFORM_FILE
    Add-Content -Value  "  type                   = `"Block`"" -Path  $TERRAFORM_FILE
    Add-Content -Value  "  source                 = `"$fullPath`"" -Path  $TERRAFORM_FILE
    Add-Content -Value  "  content_type           = `"$contentType`"" -Path  $TERRAFORM_FILE
    Add-Content -Value  "}" -Path  $TERRAFORM_FILE
    Add-Content -Value  "" -Path  $TERRAFORM_FILE

    $counter++
}

Pop-Location
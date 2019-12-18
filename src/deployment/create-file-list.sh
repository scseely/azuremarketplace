#!/bin/bash

SOURCE_FOLDER='../portal/'
DESTINATION_FOLDER='$web/'
TERRAFORM_FILE='web-file-list.tf'
EMPTY_STRING=''
rm $TERRAFORM_FILE

exec 1>>$TERRAFORM_FILE

function get_content_type {
    file_name=$1
    case $file_name in
        *.aac)      echo "audio/aac";;
        *.abw)      echo "application/x-abiword";;
        *.arc)      echo "application/x-freearc";;
        *.avi)      echo "video/x-msvideo";;
        *.azw)      echo "application/vnd.amazon.ebook";;
        *.bin)      echo "application/octet-stream";;
        *.bmp)      echo "image/bmp";;
        *.bz)       echo "application/x-bzip";;
        *.bz2)      echo "application/x-bzip2";;
        *.csh)      echo "application/x-csh";;
        *.css)      echo "text/css";;
        *.csv)      echo "text/csv";;
        *.doc)      echo "application/msword";;
        *.docx)     echo "application/vnd.openxmlformats-officedocument.wordprocessingml.document";;
        *.eot)      echo "application/vnd.ms-fontobject";;
        *.epub)     echo "application/epub+zip";;
        *.gz)       echo "application/gzip";;
        *.gif)      echo "image/gif";;
        *.htm)      echo "text/html";;
        *.html)     echo "text/html";;
        *.ico)      echo "image/vnd.microsoft.icon)";;
        *.ics)      echo "text/calendar";;
        *.jar)      echo "application/java-archive";;
        *.jpeg)     echo "image/jpeg";;
        *.jpg)      echo "image/jpeg";;
        *.js)       echo "text/javascript";;
        *.js.map)   echo "text/javascript";;
        *.json)     echo "application/json";;
        *.jsonld)   echo "application/ld+json";;
        *.md)       echo "text/plain";;
        *.mid)      echo "audio/midi audio/x-midi";;
        *.midi)     echo "audio/midi audio/x-midi";;
        *.mjs)      echo "text/javascript";;
        *.mp3)      echo "audio/mpeg";;
        *.mpeg)     echo "video/mpeg";;
        *.mpkg)     echo "application/vnd.apple.installer+xml";;
        *.odp)      echo "application/vnd.oasis.opendocument.presentation";;
        *.ods)      echo "application/vnd.oasis.opendocument.spreadsheet";;
        *.odt)      echo "application/vnd.oasis.opendocument.text";;
        *.oga)      echo "audio/ogg";;
        *.ogv)      echo "video/ogg";;
        *.ogx)      echo "application/ogg";;
        *.opus)     echo "audio/opus";;
        *.otf)      echo "font/otf";;
        *.png)      echo "image/png";;
        *.pdf)      echo "application/pdf";;
        *.php)      echo "application/php";;
        *.ppt)      echo "application/vnd.ms-powerpoint";;
        *.pptx)     echo "application/vnd.openxmlformats-officedocument.presentationml.presentation";;
        *.rar)      echo "application/x-rar-compressed";;
        *.rtf)      echo "application/rtf";;
        *.sh)       echo "application/x-sh";;
        *.svg)      echo "image/svg+xml";;
        *.tar)      echo "application/x-tar";;
        *.tif)      echo "image/tiff";;
        *.tiff)     echo "image/tiff";;
        *.ts)       echo "video/mp2t";;
        *.ttf)      echo "font/ttf";;
        *.txt)      echo "text/plain";;
        *.vsd)      echo "application/vnd.visio";;
        *.wav)      echo "audio/wav";;
        *.weba)     echo "audio/webm";;
        *.webm)     echo "video/webm";;
        *.webp)     echo "image/webp";;
        *.woff)     echo "font/woff";;
        *.woff2)    echo "font/woff2";;
        *.xhtml)    echo "application/xhtml+xml";;
        *.xls)      echo "application/vnd.ms-excel";;
        *.xlsx)     echo "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";;
        *.xml)      echo "text/xml";;
        *.xul)      echo "application/vnd.mozilla.xul+xml";;
        *.zip)      echo "application/zip";;
        *.7z)       echo "application/x-7z-compressed";;
        LICENSE)    echo "text/plain";;
        *)          echo "application/octet-stream";;
    esac

}

counter=1
for i in $(find $SOURCE_FOLDER); do # Not recommended, will break on whitespace
    if [ -f "${i}" ] ; then
        content_type=$(get_content_type $i)
        SHORT_NAME="${i//$SOURCE_FOLDER/$EMPTY_STRING}"
        echo "resource \"azurerm_storage_blob\" \"file$counter\" {"
        echo "  name                   = \"$SHORT_NAME\""
        echo "  storage_account_name   = \"\${azurerm_storage_account.az_backend.name}\""
        echo "  storage_container_name = \"\${azurerm_storage_container.web.name}\""
        echo "  type                   = \"Block\""
        echo "  source                 = \"$i\""
        echo "  content_type           = \"$content_type\""
        echo "}"
        echo ''
        let "counter=counter+1"
    fi
done



#!/bin/bash

# Description: Bash tool to transfer files from the command line.
# Usage:
#   -d  Download single file
#   -r  Delete single file
#   -h  Show the help ... 
#   -v  Get the tool version
# Examples:
#   Upload file or few files: ./transfer.sh file1 ... file(n)
#   Download file: ./transfer.sh -d file_token file_name
#   Delete file: ./transfer.sh -r file_token file_name delete_token

currentVersion="1.23.0"

params=("$@")

printUploadResponse() {
  fullLink=$(echo "$response" | grep x-url-delete | cut -d " " -f 2)
  fileID=$(echo "$fullLink" | cut -d "/" -f 4)
  fileDeleteID=$(echo "$fullLink" | cut -d "/" -f 6)
  fileURL=$(echo "$fullLink" | cut -d "/" -f 1,2,3,4,5 --output-delimiter='/')

  echo -e "File download URL: $fileURL"
  echo -e "File download token: $fileID"
  echo -e "File delete token: $fileDeleteID\n"
  #echo -e "\n$fullLink\n"
}

fileUpload() {
  echo -e "\nUploading file: $(basename "$1")\n"
  response=$(curl -#I --upload-file "$1" https://transfer.sh/"$(basename "$item")")
  echo "Transfer file: Success"
}

fileDownload() {
  local fileDownloadURL="https://transfer.sh/$1/$2"
  echo -e "\nDownloading file: $2\n"
  curl -# -O "$fileDownloadURL"
  echo "Transfer file: Success"
}

fileDlete() {
  local fileDeleteURL="https://transfer.sh/$1/$2/$3"
  echo -e "\nDeleting file: $2\n"
  curl -# -I -X DELETE "$fileDeleteURL"
  echo "Delete file: Success"
}

if [[ "$1" = "-d" ]]; then
  fileDownload "$2" "$3"
elif [[ "$1" = "-r" ]]; then
  fileDlete "$2" "$3" "$4"
elif [[ "$1" = "-v" ]]; then
  echo "Current version: $currentVersion"
elif [[ "$1" = "-h" ]]; then
  cat <<EOF
Description: Bash tool to transfer files from the command line.
Usage:
  -d  Download single file
  -r  Delete single file
  -h  Show the help ... 
  -v  Get the tool version
Examples:
  Upload file or few files: ./transfer.sh file1 ... file(n)
  Download file: ./transfer.sh -d file_token file_name
  Delete file: ./transfer.sh -r file_token file_name delete_token
EOF
else
  for item in "${params[@]}"; do
    fileUpload "$item"
    printUploadResponse
  done
fi

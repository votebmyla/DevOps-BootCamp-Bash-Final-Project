#!/bin/bash

currentVersion="1.23.0"

httpSingleUpload(){
  # Upload with "curl" tool and save result to "response" variable
  response=$(curl -A curl --upload-file "$1" "https://transfer.sh/$2") \
            || { echo "Failure!"; return 1;}
  printUploadResponse
}


printUploadResponse(){
  # Print transfer file URL
  echo "Transfer File URL: ${response}"
}

singleUpload(){
  # Iterate through filenames to upload
  for item in "$@";
  do
    # Replace '~' sign with user's home directory
    filePath=${item//~/"$HOME"}
    # Check if file exists
    if ! [ -f "$filePath" ];
    then
      echo "Error: invalid file path" 
      return 1 
    fi
    # Cut the file name and assign to the "tempFileName" variable
    tempFileName=$(echo "$item" | sed "s/.*\///")
    echo "Uploading $tempFileName"
    httpSingleUpload "${filePath}" "${tempFileName}"
  done
}

singleDownload(){
  local saveDirectory="${1}"
  local saveFileName="${3}"
  local downloadFileID="${2}"

  echo "Downloading $saveFileName"
  curl "https://transfer.sh/$downloadFileID/$saveFileName" \
        -o "${saveDirectory}/${saveFileName}" \
        || { echo "Failure!"; return 1;}
  printDownloadResponse
}

printDownloadResponse(){
  echo "Success!"
}

printDescription(){
  echo "Description: Bash tool to transfer files from the command line.
Usage:
  -d  ...
  -h  Show the help ... 
  -v  Get the tool version
Examples:
  <Couple of examples will be soon...>"
}

# Parse given options
while getopts "hvd:" options
do

  case "${options}" in
    d)
      singleDownload "$2" "$3" "$4"
      exit 0
      ;;
    v)
      echo "${currentVersion}"
      exit 0
      ;;
    h)
      printDescription
      exit 0
      ;;
    *)
      echo "usage []"
      exit 1
  esac

done

singleUpload "$@" || exit 1
#!/bin/bash

currentVersion="0.0.1"

httpSingleUpload(){
  response=$(curl -A curl --upload-file "$1" "https://transfer.sh/$2") \
            || { echo "Failure!"; return 1;}
  printUploadResponse
}


printUploadResponse(){
  # cut uploaded file ID
  # local fileID=$(echo "$response" | cut -d "/" -f 4)
  echo "${response}"
}

singleUpload(){
  # iterate files to upload
  for item in "$@";
  do
    # replace '~' sign with user's home directory
    filePath=$(echo "$item" | sed s:"~":"$HOME":g)                                    # <--------
    # check if file exists
    if ! [ -f "$filePath" ];
    then
      echo "Error: invalid file path" 
      return 1 
    fi
    # cut the file name and assign to the tempFileName variable
    tempFileName=$(echo "$item" | sed "s/.*\///")
    echo "Uploading $tempFileName"
    httpSingleUpload "${filePath}" "${tempFileName}"
  done
}

# sample file id for download: ppkkFf
# sampleID="nVjufu"

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


while getopts "hd:" options
do
  case "${options}" in
    d)
      singleDownload "$2" "$3" "$4"
      exit 0
      ;;
    v)
      echo "${currentVersion}"
      ;;
    h)
      echo "Description: Bash tool to transfer files from the command line.
Usage:
  -d  ...
  -h  Show the help ... 
  -v  Get the tool version
Examples:
  <Write a couple of examples, how to use your tool>"
      exit 0
      ;;
    *)
      exit 1
  esac
done

singleUpload "$@" || exit 1
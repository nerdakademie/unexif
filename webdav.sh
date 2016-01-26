#!/bin/bash

url=""
username=""
pw=""

function downloadFiles(){
  local path=$1
  local outputdir=$2
  for f in $(curl -s -u "$username":"$pw" "$path" | grep -Po '(?<=\<td\>\<a.href\=\")([^"]+)(?!.*\"\>Parent)')
  do
    IFS='/' read -a array <<< "$f"
    if [ "${f: -1}" == "/" ];then
      mkdir -p "$outputdir""${array[${#array[@]}-1]}"
      local folderPath="$f"
      downloadFiles "$url""$f" "$outputdir""${array[${#array[@]}-1]}""/"
      echo "$url""${folderPath::-1}"
      curl -s -u "$username":"$pw" -X DELETE "$url""${folderPath::-1}"
      echo "Deleting directory ""${array[${#array[@]}-1]}"
    else
      echo "Downloading file ""${array[${#array[@]}-1]}"" and deleting"
      curl -s -u "$username":"$pw" "$url""$f" --output "$outputdir""${array[${#array[@]}-1]}"
      curl -s -u "$username":"$pw" -X DELETE "$url""$f"
    fi
  done
}

function uploadFiles(){
  local url=$1
  local inputdir=$2"/*"
  for localFile in $inputdir
  do
    IFS='/' read -a array <<< "$localFile"
    if [ -d "$localFile" ];then
      curl -s -u "$username":"$pw" -X MKCOL "$url""${array[${#array[@]}-1]}" >/dev/null 2>&1 #Creating directory
      local Path=$localFile
      uploadFiles "$url""${array[${#array[@]}-1]}" "$localFile"
      rm -rf "$Path"
    else
      echo "Uploading file ""${array[${#array[@]}-1]}"
      curl -s -u "$username":"$pw" -T "$localFile" "$url""${array[${#array[@]}-1]}" >/dev/null 2>&1
      rm "$localFile"
    fi
  done

}


downloadFiles "$url""/webdav/I14c/Exif_remove/to_do/" "unexif/"
su -c './remove_exif.sh'

FILES=unexif
uploadFiles "$url""/webdav/I14c/Exif_remove/done/" $FILES

#!/bin/bash

if [ -f ./constants.sh ]; then
  source constants.sh
fi

userupdated=false
passupdated=false
hostupdated=false
portupdated=false
host=localhost
port=4502
user=admin
pass=admin
SERVER=${SERVER-"$host:$port"}
CREDS=${CREDS-"$user:$pass"}

while getopts "u:p:h:P:f:" opt; do
  case $opt in
    u)
      user="$OPTARG"
      userupdated=true
      ;;
    p)
      pass="$OPTARG"
      passupdated=true
      ;;
    h)
      host="$OPTARG"
      hostupdated=true
      ;;
    P)
      port="$OPTARG"
      portupdated=true
      ;;
    f)
      file="$OPTARG"
      fileupdated=true
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      ;;
  esac
done

shift "$((OPTIND-1))"
files=${file-$@}

if [ -z "${files}" ]; then
  echo "You need to pass some package files to install"
  exit 1
fi

if [ $userupdated = true ] || [ $passupdated = true ]; then
  CREDS="${user}:${pass}"
fi

if [ $hostupdated = true ] || [ $portupdated = true ]; then
  SERVER="${host}:${port}"
fi

for file in $files; do
  if [ ${file: -4} == ".zip" ]; then
    echo "Installing package ${file}"
    curl -s -u ${CREDS} -F file=@"${file}" -F force=true -F install=true http://${SERVER}/crx/packmgr/service.jsp
  elif [ ${file: -4} == ".jar" ]; then
    echo "Installing bundle ${file}"
    curl -s -u ${CREDS} -F action=install -F bundlestart=start -F bundlestartlevel=20 -F bundlefile=@"${file}" http://${SERVER}/system/console/bundles
  else
    echo "Unknown file type ${file}"
  fi
done

#!/bin/bash

host="localhost:4502"
user="admin"
pass="admin"

usage() { echo "Usage: $0 [-h <host>] [-u <username>] [-p <password>] file1..fileN" 1>&2; exit 1; }

if [[ -z "$@" ]]; then
    usage
    exit 0
fi

while getopts "Hh:u:p:" o; do
    case "${o}" in
        h)
            host=${OPTARG}
            ;;
        u)
            user=${OPTARG}
            ;;
        p)
            pass=${OPTARG}
            ;;
        H)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

files=${@}

if [ -z "${files}" ]; then
    usage
else
    for file in ${files}; do
        if [ -e "${file}" ]; then
            curl -v -u ${user}:${pass} -F file=@${file} -F force=true -F install=true http://${host}/crx/packmgr/service.jsp
        else
            echo "File $file doesn't exist."
        fi
    done
fi
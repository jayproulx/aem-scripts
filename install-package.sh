#!/bin/bash

host="localhost:4502"
user="admin"
pass="admin"

usage() { echo "Usage: $0 [-h <host>] [-u <username>] [-p <password>] file1..fileN" 1>&2; exit 1; }

if [ -z ${@} ]; then
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

echo "host = ${host}"
echo "user = ${user}"
echo "pass = ${pass}"
echo "files = ${files}"

for file in ${files}; do
    curl -v -u ${user}:${pass} -F file=@${file} -F force=true -F install=true http://${host}/crx/packmgr/service.jsp
done
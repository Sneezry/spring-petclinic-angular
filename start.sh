#!/bin/bash

FILE_PATH=$1

if [ -n "${REST_API_URL}" ]; then
    last_char=$(echo "${REST_API_URL}" | sed 's/.*\(.\)$/\1/');
    if [ "$last_char" != "/" ]; then
    REST_API_URL="${REST_API_URL}/";
    fi;
    sed -i.bak "s|http://localhost:9966/petclinic/api/|${REST_API_URL}|g" "$FILE_PATH";
else
    echo "REST_API_URL is not set, will use http://localhost:9966/petclinic/api/ as the default API endpoint.";
fi

nginx -g 'daemon off;'

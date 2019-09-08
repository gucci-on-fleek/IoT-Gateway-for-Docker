#!/bin/bash
# From https://www.sanisimov.com/2019/03/building-docker-images-for-multiple-architectures/

token=$(curl -s -X POST \
  -H "Content-Type: application/json" \
  -d '{"username": "'"$DOCKER_USERNAME"'", "password": "'"$DOCKER_PASSWORD"'"}' \
  https://hub.docker.com/v2/users/login/ | jq -r .token)

code=$(jq -n --arg msg "$(<README.md)" \
    '{"registry":"registry-1.docker.io","full_description": $msg }' | \
        curl -s -o /dev/null  -L -w "%{http_code}" \
           https://cloud.docker.com/v2/repositories/"${image}"/ \
           -d @- -X PATCH \
           -H "Content-Type: application/json" \
           -H "Authorization: JWT ${token}")

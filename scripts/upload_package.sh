#!/bin/bash

# Set variables
projectAlias="$1"
deploymentId="$2"
url="https://api-internal.umbraco.io/projects/$projectAlias/deployments/$deploymentId/package"
apiKey="$3"
file="$4"

function call_api {
  if [[ -f file]]
  then 
    response=$(curl -i -s -X POST $url \
      -H "Umbraco-Api-Key: $apiKey" \
      -H "Content-Type: multipart/form-data" \
      --form "file=@$file")

    echo "$response"
  else
    echo "no file on path"
    exit 1
  fi
}

call_api

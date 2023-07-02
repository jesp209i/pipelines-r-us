#!/bin/bash

# Set variables
projectAlias="$1"
deploymentId="$2"
url="https://api-internal.umbraco.io/projects/$projectAlias/deployments/$deploymentId"
apiKey="$3"

# Define function to call API to start thedeployment
function call_api {
  echo "$url"
  response=$(curl -s -X PATCH $url \
    -H "Umbraco-Api-Key: $apiKey" \
    -H "Content-Type: application/json" \
    -d "")
  echo "$response"
  # http status 202 expected here
  # extract status for validation
  status=$(echo "$response" | jq -r '.deploymentState')
  if [[ $status != "Queued" ]]; then
    echo "Unexpected status: $status"
    exit 1
  fi
}

# sleep a little to allow for background tasks to fetch project metadata - need state management for this
echo "sleeping a bit to let service do their things"

sleep 15

call_api

echo "Deployment started successfully -> $deployment_id"

#!/bin/bash

# Set variables
projectAlias="$1"
url="https://api-internal.umbraco.io/projects/$projectAlias/deployments/"
apiKey="$2"
commitMessage="$3"

# Define function to call API and check status
function call_api {
  echo "Posting to $url with commit message: $commitMessage"
  response=$(curl -s -X POST $url \
    -H "Umbraco-Api-Key: $apiKey" \
    -H "Content-Type: application/json" \
    -d "{\"commitMessage\":\"$commitMessage\"}")
  echo "$response"
  # extract status and deploymentId for validation and later use
  status=$(echo "$response" | jq -r '.deploymentState')
  deployment_id=$(echo "$response" | jq -r '.deploymentId')
  if [[ $status != "Created" ]]; then
    echo "Unexpected status: $status"
    exit 1
  fi
  echo "$deployment_id"
}

call_api

echo "Deployment created successfully -> $deployment_id"

# store deploymentId for later stages
echo "DEPLOYMENT_ID=$deployment_id" >> "$GITHUB_OUTPUT"

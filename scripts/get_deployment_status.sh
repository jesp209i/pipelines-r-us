#!/bin/bash

# Set variables
projectAlias="$1"
deploymentId="$2"
url="https://api-internal.umbraco.io/projects/$projectAlias/deployments/$deploymentId"
apiKey="$3"

# Define function to call API and check status
function call_api {
  response=$(curl -s -X GET $url \
    -H "Umbraco-Api-Key: $apiKey" \
    -H "Content-Type: application/json")
  echo "$response"
  status=$(echo $response | jq -r '.deploymentState')
}

# Call API and check status
call_api
while [[ $status == "Pending" || $status == "InProgress" || $status == "Queued" ]]; do
  echo "Status is $status, waiting 15 seconds..."
  sleep 15
  call_api
  # Wait max 20 minutes. This is a variable value depending on your project
  if [[ $SECONDS -gt 1200 ]]; then
    echo "Timeout reached, exiting loop."
    break
  fi
done

# Check final status
if [[ $status == "Completed" ]]; then
  echo "Deployment completed successfully."
elif [[ $status == "Failed" ]]; then
  echo "Deployment failed."
  exit 1
else
  echo "Unexpected status: $status"
  exit 1
fi

#!/bin/bash

# Set required variables
patchFile="$1"
latestDeploymentId="$2"

# Not required, defaults to:
gitUserName="$3" # github-actions
gitUserEmail="$4"  # github-actions@github.com

if [[ -z "$gitUserName" ]]; then
    gitUserName="github-actions"
fi

if [[ -z "$gitUserEmail" ]]; then
    gitUserEmail="github-actions@github.com"
fi

git config user.name $githubUserName
git config user.email $githubUserEmail
# Check if the patch has been applied already, skip if it has
if git apply $patchFile --reverse --ignore-space-change --ignore-whitespace --check; then
    echo "Patch already applied, exit"
    exit 0
# check if the patch can be applied
elif git apply $patchFile --ignore-space-change --ignore-whitespace --check; then
    echo "Patch needed, trying now"
    git apply $patchFile --ignore-space-change --ignore-whitespace
    git add *
    git commit -m "Adding cloud changes since deployment $latestDeploymentId [skip ci]"
    git push
    # record the new sha for the deploy
    updatedSha=$(git rev-parse HEAD)
    echo "Updated SHA: $updatedSha"
    echo "updatedSha=$updatedSha" >> "$GITHUB_OUTPUT"
fi
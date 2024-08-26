param (
    [string]$patchFile,
    [string]$latestDeploymentId,
    [string]$gitUserName = "github-actions",
    [string]$gitUserEmail = "github-actions@github.com"
)


git config user.name $gitUserName
git config user.email $gitUserEmail

# Check if the patch has been applied already, skip if it has
if (git apply $patchFile --reverse --ignore-space-change --ignore-whitespace --check) {
    Write-Output "Patch already applied, exit"
    exit 0
}
# Check if the patch can be applied
elseif (git apply $patchFile --ignore-space-change --ignore-whitespace --check) {
    Write-Output "Patch needed, trying now"
    git apply $patchFile --ignore-space-change --ignore-whitespace
    git add *
    git commit -m "Adding cloud changes since deployment $latestDeploymentId [skip ci]"
    git push
    # Record the new sha for the deploy
    $updatedSha = git rev-parse HEAD
    Write-Output "Updated SHA: $updatedSha"
    Add-Content -Path $env:GITHUB_OUTPUT -Value "updatedSha=$updatedSha"
}


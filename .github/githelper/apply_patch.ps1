param (
    [Parameter(Position=0)]
    [string]
    $PatchFile,
    
    [Parameter(Position=1)]
    [string]
    $LatestDeploymentId,
    
    [Parameter(Position=3)]
    [string]
    $PipelineVendor,

    [Parameter(Position=3)]
    [string]
    $GitUserName = "github-actions",
    
    [Parameter(Position=4)]
    [string]
    $GitUserEmail = "github-actions@github.com"
)

Write-Host "PatchFile: $PatchFile"
Write-Host "LatestDeploymentId: $LatestDeploymentId"
Write-Host "PipelineVendor: $PipelineVendor"
Write-Host "GitUserName: $GitUserName"
Write-Host "GitUserEmail: $GitUserEmail"


git config user.name $GitUserName
git config user.email $GitUserEmail

# Check if the patch has been applied already, skip if it has
if (git apply $PatchFile --reverse --ignore-space-change --ignore-whitespace --check) {
    Write-Output "Patch already applied => concluding the apply patch part"
    exit 0
}
# Check if the patch can be applied
elseif (git apply $PatchFile --ignore-space-change --ignore-whitespace --check) {
    Write-Output "Patch needed, trying now"
    git apply $PatchFile --ignore-space-change --ignore-whitespace
    git add *
    git commit -m "Adding cloud changes since deployment $LatestDeploymentId [skip ci]"
    git push
    # Record the new sha for the deploy
    $updatedSha = git rev-parse HEAD
    Write-Output "Updated SHA: $updatedSha"

    switch ($PipelineVendor) {
        "GITHUB" {
            "updatedSha=$($updatedSha)" | Out-File -FilePath $env:GITHUB_OUTPUT -Append
        }
        "AZUREDEVOPS" {
            Write-Host "##vso[task.setvariable variable=updatedSha;]$($updatedSha)"
        }
        "TESTRUN" {
            Write-Host $PipelineVendor
        }
        Default {
            Write-Host "Please use one of the supported Pipeline Vendors or enhance script to fit your needs"
            Write-Host "Currently supported are: GITHUB and AZUREDEVOPS"
            Exit 1
        }
    }
}
else {

    Write-Output "Patch cannot be applied - please check the output below for the problematic parts"
    Write-Output "================================================================================="
    git apply --reject $PatchFile --ignore-space-change --ignore-whitespace --check
    exit 1
}


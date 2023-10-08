param(
    $BaseUrl,
    $ProjectId,
    $ApiKey,
    $CommitMessage
)

$Headers = @{
    'Umbraco-Cloud-Api-Key' = $ApiKey
    'Content-Type' = 'application/json'
}

$Body = @{
    'commitMessage' = $CommitMessage
} | ConvertTo-Json

$Url = "$BaseUrl/v1/projects/$ProjectId/deployments"

function Create-Deployment {
    Write-Host "Posting to $Url with commit message: $CommitMessage"
    $Response = Invoke-RestMethod -URI $Url -Headers $Headers -Method POST -Body $Body
    $Status = $Response.deploymentState
    $DeploymentId = $Response.deploymentId

    if ($Status -eq "Created") {

        Write-Host $Response.updateMessage

        "DEPLOYMENT_ID=$($DeploymentId)" | Out-File -FilePath $env:GITHUB_OUTPUT -Append

        Write-Host "Deployment Created Successfully => $($DeploymentId)"
        return
    }

    throw "Unexpected Response from Api"
}

Create-Deployment
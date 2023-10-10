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
    try {
        $Response = Invoke-RestMethod -URI $Url -Headers $Headers -Method POST -Body $Body
        $Status = $Response.deploymentState
        $DeploymentId = $Response.deploymentId

        if ($Status -eq "Created") {

            Write-Host $Response.updateMessage

            "DEPLOYMENT_ID=$($DeploymentId)" | Out-File -FilePath $env:GITHUB_OUTPUT -Append

            Write-Host "Deployment Created Successfully => $($DeploymentId)"
            exit 0
        }
        
        Write-Host "---Response Start---"
        Write-Host $Response
        Write-Host "---Response End---"
        Write-Host "Unexpected response - see above"
        exit 1
    }
    catch {
        Write-Host "---Error---"
        Write-Host "StatusCode:" $_.Exception.Response.StatusCode.value__ 
        Write-Host "StatusDescription:" $_.Exception.Response.StatusDescription
        exit 1
    }
}

Create-Deployment
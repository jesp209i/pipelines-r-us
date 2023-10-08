param(
    $BaseUrl,
    $ProjectId,
    $DeploymentId,
    $ApiKey
)

$Headers = @{
    'Umbraco-Cloud-Api-Key' = $ApiKey
    'Content-Type' = 'application/json'
}

$Body = @{
    'deploymentState' = 'Queued'
} | ConvertTo-Json

$Url = "$BaseUrl/v1/projects/$ProjectId/deployments"

function Start-Deployment {
    Write-Host "Requesting start Deployment at $Url"
    $Response = Invoke-RestMethod -URI $Url -Headers $Headers -Method PATCH -Body $Body
    $Status = $Response.deploymentState

    if ($Status -eq "Queued") {
        Write-Host $Response.updateMessage
        return
    }

    throw "Unexpected Response from Api"
}

Start-Deployment
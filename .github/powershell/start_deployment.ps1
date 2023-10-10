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

$Url = "$BaseUrl/v1/projects/$ProjectId/deployments/$DeploymentId"

function Start-Deployment {
    try {
        Write-Host "Requesting start Deployment at $Url"
        $Response = Invoke-RestMethod -URI $Url -Headers $Headers -Method PATCH -Body $Body
        $Status = $Response.deploymentState

        if ($Status -eq "Queued") {
            Write-Host $Response.updateMessage
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

Start-Deployment
param(
    $BaseUrl,
    $ProjectId,
    $DeploymentId,
    $ApiKey
)

$TimeoutSeconds = 1200
$timer = [Diagnostics.Stopwatch]::StartNew()

$Headers = @{
    'Umbraco-Cloud-Api-Key' = $ApiKey
    'Content-Type' = 'application/json'
}
$Url = "$BaseUrl/v1/projects/$ProjectId/deployments/$DeploymentId"

function Get-Deployment-Status ([INT]$Run){
    Write-Host "=====> Requesting Status - Run number $Run"
    $Response = Invoke-WebRequest -URI $Url -Headers $Headers 
    if ($Response.StatusCode -eq 200) {

        $JsonResponse = ConvertFrom-Json $([String]::new($response.Content))

        Write-Host $JsonResponse.updateMessage
        return $JsonResponse.deploymentState
    }

    throw "Unexpected Response from Api"
}

while ($timer.Elapsed.TotalSeconds -lt $TimeoutSeconds) {
    $Run = 1
    $DeploymentStatus = Get-Deployment-Status($Run)

    $StatusesBeforeCompleted = ("Pending", "InProgress", "Queued")

    while ($StatusesBeforeCompleted -contains $DeploymentStatus) {
        if ($timer.Elapsed.TotalSeconds -gt $TimeoutSeconds){
            throw "Timeout was reached"
        }
        Write-Host "=====> Still Deploying - sleeping for 15 seconds"
        Start-Sleep -Seconds 15
        $Run++
        $DeploymentStatus = Get-Deployment-Status($Run)
    }

    $timer.Stop()

    if ($DeploymentStatus -eq 'Completed'){
        Write-Host "Deployment completed successfully"
        
        return
    }
    if ($DeploymentStatus -eq 'Failed'){
        throw "Deployment Failed"
    }

    Write-Host "Unexpected status: $DeploymentStatus"
}

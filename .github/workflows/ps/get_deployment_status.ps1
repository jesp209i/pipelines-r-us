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
    Write-Host "Run $Run"
    $Response = Invoke-RestMethod -URI $Url -Headers $Headers 
    if ($Response.statusCode -eq 200) {
        Write-Host $Response.updateMessage
        return $Response.deploymentState
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
        Write-Host "Deployment was not ready - sleeping for 15 seconds"
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

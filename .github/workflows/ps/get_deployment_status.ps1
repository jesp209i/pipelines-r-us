$BaseUrl = $args[0]
$ProjectId = $args[1]
$DeploymentId = $args[2]
$ApiKey = $args[3]

$TimeoutSeconds = 1200
$timer = [Diagnostics.Stopwatch]::StartNew()

$Headers = @{
    'Umbraco-Cloud-Api-Key' = $ApiKey
    'Content-Type' = 'application/json'
}
$Url = "$BaseUrl/v1/projects/$ProjectId/deployments/$DeploymentId"

function Get-Deployment-Status ([INT]$Run){
    $Response = Invoke-RestMethod -URI $Url -Headers $Headers 
    Write-Host "Run $Run " #$Response.updateMessage"
    Write-Host $timer.Elapsed.TotalSeconds ($timer.Elapsed.TotalSeconds -lt $TimeoutSeconds)
    return $Response.deploymentState
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

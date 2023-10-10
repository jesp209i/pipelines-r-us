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
    try {
        $Response = Invoke-WebRequest -URI $Url -Headers $Headers 
        if ($Response.StatusCode -eq 200) {

            $JsonResponse = ConvertFrom-Json $([String]::new($response.Content))

            Write-Host $JsonResponse.updateMessage
            return $JsonResponse.deploymentState
        }
    }
    catch 
    {
        Write-Host "---Error---"
        Write-Host "StatusCode:" $_.Exception.Response.StatusCode.value__ 
        Write-Host "StatusDescription:" $_.Exception.Response.StatusDescription
        exit 1
    }
}

while ($timer.Elapsed.TotalSeconds -lt $TimeoutSeconds) {
    $Run = 1
    
    $StatusesBeforeCompleted = ("Pending", "InProgress", "Queued")

    do {
        $DeploymentStatus = Get-Deployment-Status($Run)
        if ($timer.Elapsed.TotalSeconds -gt $TimeoutSeconds){
            throw "Timeout was reached"
        }
        Write-Host "=====> Still Deploying - sleeping for 15 seconds"
        Start-Sleep -Seconds 15
        $Run++
    } while (
        $StatusesBeforeCompleted -contains $DeploymentStatus
    )

    $timer.Stop()

    if ($DeploymentStatus -eq 'Completed'){
        Write-Host "Deployment completed successfully"
        exit 0
    }
    if ($DeploymentStatus -eq 'Failed'){
        Write-Host "Deployment Failed"
        exit 1 
    }

    Write-Host "Unexpected status: $DeploymentStatus"
    exit 1
}

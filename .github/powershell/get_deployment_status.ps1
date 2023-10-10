param(
    $BaseUrl,
    $ProjectId,
    $DeploymentId,
    $ApiKey
)

# Set a reasonable time for deployment to finish
# 1200 sec = 20 minutes should be enough, but can be set higher
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
        Write-Host $_
        exit 1
    }
}

while ($timer.Elapsed.TotalSeconds -lt $TimeoutSeconds) {
    $Run = 1
    
    $StatusesBeforeCompleted = ("Pending", "InProgress", "Queued")

    do {
        $DeploymentStatus = Get-Deployment-Status($Run)
        $Run++

        # Handle timeout
        if ($timer.Elapsed.TotalSeconds -gt $TimeoutSeconds){
            throw "Timeout was reached"
        }
        
        # Dont write if Deployment was finished
        if ($StatusesBeforeCompleted -contains $DeploymentStatus){
            Write-Host "=====> Still Deploying - sleeping for 15 seconds"
            Start-Sleep -Seconds 15
        }

    } while (
        $StatusesBeforeCompleted -contains $DeploymentStatus
    )

    $timer.Stop()

    # Successfully deployed to cloud
    if ($DeploymentStatus -eq 'Completed'){
        Write-Host "Deployment completed successfully"
        exit 0
    }

    # Deployment has failed
    if ($DeploymentStatus -eq 'Failed'){
        Write-Host "Deployment Failed"
        exit 1 
    }

    # Unexpected deployment status - considered a fail
    Write-Host "Unexpected status: $DeploymentStatus"
    exit 1
}

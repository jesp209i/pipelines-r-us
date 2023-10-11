function Start-Deployment {
    [CmdletBinding()]
    param(
        $baseUrl,
        $projectId,
        $deploymentId,
        $apiKey
    )

    $headers = @{
        'Umbraco-Cloud-Api-Key' = $apiKey
        'Content-Type' = 'application/json'
    }

    $body = @{
        'deploymentState' = 'Queued'
    } | ConvertTo-Json

    $url = "$baseUrl/v1/projects/$projectId/deployments/$deploymentId"


    try {
        Write-Host "Requesting start Deployment at $url"
        $response = Invoke-RestMethod -URI $url -Headers $headers -Method PATCH -Body $body
        $status = $response.deploymentState

        if ($status -eq "Queued") {
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
        Write-Host $_
        exit 1
    }
}
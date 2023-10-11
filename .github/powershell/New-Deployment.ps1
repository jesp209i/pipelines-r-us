function New-Deployment {
    param(
        [string] $baseUrl,
        [string] $projectId,
        [string] $apiKey,
        [string] $commitMessage,
        [string] $pipelineVendor
    )

    $headers = @{
        'Umbraco-Cloud-Api-Key' = $apiKey
        'Content-Type' = 'application/json'
    }

    $body = @{
        'commitMessage' = $commitMessage
    } | ConvertTo-Json

    $url = "$baseUrl/v1/projects/$projectId/deployments"

    Write-Host "Posting to $url with commit message: $commitMessage"
    try {
        $response = Invoke-RestMethod -URI $url -Headers $headers -Method POST -Body $body
        $status = $response.deploymentState
        $deploymentId = $response.deploymentId

        if ($status -eq "Created") {

            Write-Host $response.updateMessage

            switch ($pipelineVendor) {
                "GITHUB" {
                    "DEPLOYMENT_ID=$($deploymentId)" | Out-File -FilePath $env:GITHUB_OUTPUT -Append
                  }
                  "AZUREDEVOPS" {
                    Write-Host "##vso[task.setvariable variable=deploymentId;]$($deploymentId)"
                  }
                Default {
                    Write-Host "Please use one of the supported Pipeline Vendors or enhance script to fit your needs"
                    Write-Host "Currently supported are: GITHUB and AZUREDEVOPS"
                    Exit 1
                }
            }

            Write-Host "Deployment Created Successfully => $($deploymentId)"
            exit 0
        }

        Write-Host "---Response Start---"
        Write-Host $response
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
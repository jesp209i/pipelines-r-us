param(
    $BaseUrl,
    $ProjectId,
    $ApiKey,
    $CommitMessage,
    $PipelineVendor
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

            switch ($PipelineVendor) {
                "GITHUB" {
                    "DEPLOYMENT_ID=$($DeploymentId)" | Out-File -FilePath $env:GITHUB_OUTPUT -Append
                  }
                  "AZUREDEVOPS" {
                    Write-Host "##vso[task.setvariable variable=deploymentId;]$($DeploymentId)"
                  }
                Default {
                    Write-Host "Please use one of the supported Pipeline Vendors or enhance script to fit your needs"
                    Write-Host "Currently supported are: GITHUB and AZUREDEVOPS"
                    Exit 1
                }
            }

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
        Write-Host $_
        exit 1
    }
}

Create-Deployment
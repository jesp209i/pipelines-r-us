
# Set variables
param(
    $BaseUrl,
    $ProjectId,
    $ApiKey,
    $DownloadFolder
)


$DeploymentUrl = "$BaseUrl/v1/projects/$ProjectId/deployments"

$Headers = @{
  'Umbraco-Cloud-Api-Key' = $ApiKey
  'Content-Type' = 'application/json'
}

# Get latest deployment id
function Get-Latest-DeploymentId {
  $LatestDeploymentUrl = "$($DeploymentUrl)?skip=0&take=1"
    $Response = Invoke-WebRequest -URI $LatestDeploymentUrl -Headers $Headers 
    if ($Response.StatusCode -eq 200) {
        # Only fetching the latest one, but endpoint returns a list
        $JsonResponse = ConvertFrom-Json $([String]::new($response.Content))

        return $JsonResponse.deployments[0].deploymentId
        #return '229dc5c0-0a97-44d8-88e3-f90cc79fb4c8'
    }

    throw "Unexpected Response from Api"
}


# Get diff - stores file as git-patch.diff
function Get-Changes ($DeploymentId) {
  if (!(Test-Path $DownloadFolder -PathType Container)) { # ensure folder exists
      New-Item -ItemType Directory -Force -Path $DownloadFolder
  }
  
  $ChangeUrl="$($DeploymentUrl)/$($DeploymentId)/diff"
  Write-Host $ChangeUrl
  
  $Response = Invoke-WebRequest -URI $ChangeUrl -Headers $Headers
  $StatusCode = $Response.StatusCode
  Write-Host $StatusCode
  # Extract the responsebody into a file
  $Response | Select-Object -ExpandProperty Content | Out-File "$DownloadFolder/git-patch.diff"
  
  return $StatusCode
}

$LatestDeploymentId = Get-Latest-DeploymentId

try {

  $DiffStatusCode = Get-Changes($LatestDeploymentId)
  Write-Host "diffstatus is $DiffStatusCode"
  if ($DiffStatusCode -eq '204'){
    Write-Host "No Changes"
    ## TODO write to github that no changes is registered
    #"REMOTE_CHANGES=false" | Out-File -FilePath $env:GITHUB_OUTPUT -Append
    return
  }

  if ($DiffStatusCode -eq '200'){
    Write-Host "Changes registered - check file: $DownloadFolder/git-patch.diff"
    ## TODO write to github that changes are registered
    #"REMOTE_CHANGES=true" | Out-File -FilePath $env:GITHUB_OUTPUT -Append
    #"latestDeploymentId=$LatestDeploymentId" | Out-File -FilePath $env:GITHUB_OUTPUT -Append
    #"REMOTE_CHANGE_FILE=git-patch.diff" | Out-File -FilePath $env:GITHUB_OUTPUT -Append
    return
  }
}
catch {
  $StatusCode = $_.Exception.Response.StatusCode.value__
  throw "Unexpected Statuscode $StatusCode"
}
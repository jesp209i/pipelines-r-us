#Set Variables
param(
    $BaseUrl,
    $ProjectId,
    $DeploymentId,
    $ApiKey,
    $FilePath
)
$Url = "$BaseUrl/v1/projects/$ProjectId/deployments/$DeploymentId/package"

$FieldName = 'file'
$ContentType = 'application/zip'
$UmbracoHeader = @{ 'Umbraco-Cloud-Api-Key' = $ApiKey }

function Upload-Package {
    $FileStream = [System.IO.FileStream]::new($FilePath, [System.IO.FileMode]::Open)
    $FileHeader = [System.Net.Http.Headers.ContentDispositionHeaderValue]::new('form-data')
    $FileHeader.Name = $FieldName
    $FileHeader.FileName = Split-Path -leaf $FilePath
    $FileContent = [System.Net.Http.StreamContent]::new($FileStream)
    $FileContent.Headers.ContentDisposition = $FileHeader
    $FileContent.Headers.ContentType = [System.Net.Http.Headers.MediaTypeHeaderValue]::Parse($ContentType)

    $MultipartContent = [System.Net.Http.MultipartFormDataContent]::new()
    $MultipartContent.Add($FileContent)

    $Response = Invoke-WebRequest -Body $MultipartContent -Headers $UmbracoHeader  -Method 'POST' -Uri $Url
    if ($Response.StatusCode -ne 202)
    {
        throw "Error during upload"
    }
    Write-Host $Response.Content | ConvertTo-Json
}

Upload-Package
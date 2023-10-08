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
$ContentType = 'application/json'

$FileStream = [System.IO.FileStream]::new($FilePath, [System.IO.FileMode]::Open)
$FileHeader = [System.Net.Http.Headers.ContentDispositionHeaderValue]::new('form-data')
$FileHeader.Name = $FieldName
$FileHeader.FileName = Split-Path -leaf $FilePath
$FileContent = [System.Net.Http.StreamContent]::new($FileStream)
$FileContent.Headers.ContentDisposition = $FileHeader
$FileContent.Headers.ContentType = [System.Net.Http.Headers.MediaTypeHeaderValue]::Parse($ContentType)
$FileContent.Headers.Add("Umbraco-Api-Key", $ApiKey)

$MultipartContent = [System.Net.Http.MultipartFormDataContent]::new()
$MultipartContent.Add($FileContent)

$Response = Invoke-WebRequest -Body $MultipartContent -Method 'POST' -Uri $Url

Write-Host $Response
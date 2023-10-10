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

    try {
        $Response = Invoke-WebRequest -Body $MultipartContent -Headers $UmbracoHeader  -Method 'POST' -Uri $Url
        if ($Response.StatusCode -ne 202)
        {
            Write-Host "---Response Start---"
            Write-Host $Response
            Write-Host "---Response End---"
            Write-Host "Unexpected response - see above"
            exit 1
        }

        Write-Host $Response.Content | ConvertTo-Json
        exit 0
    }
    catch 
    {
        Write-Host "---Error---"
        Write-Host "StatusCode:" $_.Exception.Response.StatusCode.value__ 
        Write-Host "StatusDescription:" $_.Exception.Response.StatusDescription
        exit 1
    }
}

Upload-Package
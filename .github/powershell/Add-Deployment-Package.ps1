function Add-Deployment-Package {
    [CmdletBinding()]
    param(
        [string] $baseUrl,
        [string] $projectId,
        [string] $apiKey,
        [string] $deploymentId,
        [string] $filePath
    )

    $url = "$baseUrl/v1/projects/$projectId/deployments/$deploymentId/package"

    $fieldName = 'file'
    $contentType = 'application/zip'
    $umbracoHeader = @{ 'Umbraco-Cloud-Api-Key' = $ApiKey }


    $fileStream = [System.IO.FileStream]::new($filePath, [System.IO.FileMode]::Open)
    $fileHeader = [System.Net.Http.Headers.ContentDispositionHeaderValue]::new('form-data')
    $fileHeader.Name = $fieldName
    $fileHeader.FileName = Split-Path -leaf $filePath
    $fileContent = [System.Net.Http.StreamContent]::new($fileStream)
    $fileContent.Headers.ContentDisposition = $fileHeader
    $fileContent.Headers.ContentType = [System.Net.Http.Headers.MediaTypeHeaderValue]::Parse($contentType)

    $multipartContent = [System.Net.Http.MultipartFormDataContent]::new()
    $multipartContent.Add($fileContent)

    try {
        $response = Invoke-WebRequest -Body $multipartContent -Headers $umbracoHeader  -Method 'POST' -Uri $url
        if ($response.StatusCode -ne 202)
        {
            Write-Host "---Response Start---"
            Write-Host $response
            Write-Host "---Response End---"
            Write-Host "Unexpected response - see above"
            exit 1
        }

        Write-Host $response.Content | ConvertTo-Json
        exit 0
    }
    catch 
    {
        Write-Host "---Error---"
        Write-Host $_
        exit 1
    }
}
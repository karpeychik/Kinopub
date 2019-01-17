
function Add-Files([System.IO.Compression.ZipArchive]$archive, [string]$entryRoot, $files)
{
    foreach($file in $files)
    {
        $item = Get-Item -path $file
        $entryName = [System.IO.Path]::Combine($entryRoot,$item.Name)
        Write-Host "Adding $entryName"
        $fileStream = New-Object "System.IO.FileStream" -ArgumentList @("$file", [System.IO.FileMode]::Open)
        $entry = $archive.CreateEntry($entryName, [System.IO.Compression.CompressionLevel]::Fastest)
        $entryStream = $entry.Open()
        $fileStream.CopyTo($entryStream)
        $fileStream.Dispose()
        $entryStream.Dispose()
    }
}

function Get-FilePaths([string]$path)
{
    $result = @()
    $files = Get-ChildItem -Path $path
    foreach($file in $files)
    {
        $result += $file.FullName
    }

    return $result
}

Add-Type -assembly "system.io.compression" 

$dir = [System.IO.Path]::GetDirectoryName($myInvocation.MyCommand.Definition)
$archivePath = "$dir\out\KinoPub.zip"
if ([System.IO.File]::Exists($archivePath))
{
    Remove-Item -Path $archivePath
}

Write-Host "Creating release in $archivePath"

$components = "$dir\..\KinoPub\components"
$images = "$dir\..\KinoPub\images"
$fonts = "$dir\..\KinoPub\fonts"
$source = "$dir\..\KinoPub\source"

$manifest = "$dir\..\KinoPub\manifest"

$stream = New-Object "System.IO.FileStream" -ArgumentList @($archivePath, [System.IO.FileMode]::CreateNew)
$archive = New-Object "System.IO.Compression.ZipArchive" -ArgumentList @($stream, [System.IO.Compression.ZipArchiveMode]::Create)
Add-Files -archive $archive -entryRoot "components" -files (Get-FilePaths -path $components)
Add-Files -archive $archive -entryRoot "source" -files (Get-FilePaths -path $source)
Add-Files -archive $archive -entryRoot "fonts" -files (Get-FilePaths -path $fonts)
Add-Files -archive $archive -entryRoot "images" -files (Get-FilePaths -path $images)
Add-Files -archive $archive -entryRoot "" -files @($manifest)

$archive.Dispose()
$stream.Dispose()

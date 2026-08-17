#!/usr/bin/env pwsh

# Script to install and update ffmpeg on Windows x86_64
# Author: dmesg00@duck.com

function Install-FFmpeg {
    $ffmpegUrl = "https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl.zip"
    $tempPath = "$env:TEMP\ffmpeg.zip"
    $installPath = "C:\Users\$env:USERNAME\ffmpeg"

    Write-Host "Downloading FFmpeg..."
    Remove-Item -Path $tempPath -ErrorAction SilentlyContinue
    Invoke-WebRequest -Uri $ffmpegUrl -OutFile $tempPath

    Write-Host "Installing FFmpeg..."
    Remove-Item -Path $installPath -Recurse -Force -ErrorAction SilentlyContinue
    New-Item -Path $installPath -ItemType Directory -Force
    Expand-Archive -Path $tempPath -DestinationPath $installPath

    $extractedPath = Join-Path -Path $installPath -ChildPath "ffmpeg-master-latest-win64-gpl\bin"
    if (Test-Path -Path $extractedPath) {
        Move-Item -Path "$extractedPath\*" -Destination "$installPath" -Force
        Remove-Item -Path "$installPath\ffmpeg-master-latest-win64-gpl" -Recurse -Force
    }

    Remove-Item -Path $tempPath -ErrorAction SilentlyContinue

    $currentPath = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::User)
    if (-not ($currentPath -like "*$installPath*")) {
        [System.Environment]::SetEnvironmentVariable("Path", "$currentPath;$installPath", [System.EnvironmentVariableTarget]::User)
        Write-Host "Added FFmpeg to user PATH."
    }

    Write-Host "Installation of FFmpeg done."
}

$versionUrl = "https://github.com/BtbN/FFmpeg-Builds/releases/tag/latest"
$versionContent = Invoke-WebRequest -Uri $versionUrl
if ($versionContent.Content -match '<title>(.*?)<\/title>') {
    $versionFFmpeg = $matches[1]
} else {
    Write-Host "Could not detect FFmpeg version."
    exit
}

$versionFilePath = "$env:USERPROFILE\ffmpeg_version.conf"

if (Test-Path -Path $versionFilePath) {
    $currentVersion = Get-Content -Path $versionFilePath
} else {
    $currentVersion = ""
}

if ($versionFFmpeg -ne $currentVersion) {
    Write-Host "New FFmpeg version detected: $versionFFmpeg"
    Install-FFmpeg
    if ($?) {
        Set-Content -Path $versionFilePath -Value $versionFFmpeg
    }
} else {
    Write-Host "No updates for FFmpeg."
}

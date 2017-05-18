param(
    [string][parameter()][ValidateSet("agent", "server")]$app,
    [string][parameter()][ValidateNotNullOrEmpty()]$version = $env:version,
    [string][parameter()][ValidateNotNullOrEmpty()]$revision = $env:revision
)

function Get-ChecksumForFile($url) {
    $tempFile = [System.IO.Path]::GetTempFileName()
    Invoke-WebRequest -Uri $url -OutFile $tempFile
    $hash = Get-FileHash -Path $tempFile -Algorithm "sha256"
    Remove-Item $tempFile

    return $hash.Hash
}

$path = "gocd-" + $app
$fullVersion = $version + "-" + $revision

$url = "https://download.gocd.io/binaries/$fullVersion/win/go-$app-$fullVersion-jre-32bit-setup.exe"
$url64 = "https://download.gocd.io/binaries/$fullVersion/win/go-$app-$fullVersion-jre-64bit-setup.exe"

$replacements = @{
    '{{app}}' = $app
    '{{url}}' = $url
    '{{checksum}}' = Get-ChecksumForFile $url
    '{{url64}}' = $url64
    '{{checksum64}}' = Get-ChecksumForFile $url64
}

Push-Location $path
mkdir -Force "tools" | Out-Null

$script = Get-Content "$PSScriptRoot\chocolateyInstall.ps1.template"

foreach ($token in $replacements.Keys) {
    $script = $script -replace $token, $replacements.Item($token)
}

$script | out-file tools\chocolateyInstall.ps1;

choco pack --version=$version

Pop-Location
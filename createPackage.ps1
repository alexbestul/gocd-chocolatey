param(
    [string][parameter()][ValidateSet("agent", "server")]$app,
    [string][parameter()][ValidateNotNullOrEmpty()]$version = $env:version,
    [string][parameter()][ValidateNotNullOrEmpty()]$revision = $env:revision
)

$path = "gocd-" + $app
$fullVersion = $version + "-" + $revision

$replacements = @{
    '{{url}}' = "https://download.gocd.io/binaries/$fullVersion/win/go-$app-$fullVersion-jre-32bit-setup.exe"
    '{{url64}}' = "https://download.gocd.io/binaries/$fullVersion/win/go-$app-$fullVersion-jre-64bit-setup.exe"
}

Push-Location $path

$script = Get-Content tools\chocolateyInstall.ps1.template

foreach ($token in $replacements.Keys) {
    $script = $script -replace $token, $replacements.Item($token)
}

$script | out-file tools\chocolateyInstall.ps1;

choco pack --version=$version

Pop-Location
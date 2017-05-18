param(
    [string][parameter()][ValidateSet("agent", "server")]$app,
    [string][parameter()][ValidateNotNullOrEmpty()]$version = $env:version,
    [string][parameter()][ValidateNotNullOrEmpty()]$revision = $env:revision
)

$path = "gocd-" + $app
$fullVersion = $version + "-" + $revision

Push-Location $path

(Get-Content tools\chocolateyInstall.ps1.template) -replace '{{fullVersion}}', $fullVersion | out-file tools\chocolateyInstall.ps1;
choco pack --version=$version

Pop-Location
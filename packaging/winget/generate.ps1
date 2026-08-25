# SHA256 values come from checksums.txt. This script does not invent them.
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Version,

    [Parameter(Mandatory = $true)]
    [string]$ChecksumsPath,

    [string]$Owner = 'daveyb',

    [string]$Repo = 'cliamp',

    [string]$PackageIdentifier = 'Daveyb.Cliamp',

    [string]$OutDir = '',

    [string]$Amd64InstallerUrl = '',

    [string]$Arm64InstallerUrl = ''
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($OutDir)) {
    $OutDir = Join-Path -Path $PSScriptRoot -ChildPath 'manifests'
}

$Version = $Version.Trim()
if ($Version.StartsWith('v') -or $Version.StartsWith('V')) {
    $Version = $Version.Substring(1)
}
if ($Version -notmatch '^[0-9]') {
    throw "Version must be a numeric package version, got '$Version'"
}

$Tag = "v$Version"

if (-not (Test-Path -LiteralPath $ChecksumsPath)) {
    throw "checksums.txt not found: $ChecksumsPath"
}

function Get-ChecksumSha256 {
    param(
        [Parameter(Mandatory = $true)]
        [string]$AssetName,

        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [string[]]$Lines
    )

    foreach ($line in $Lines) {
        $trim = $line.Trim()
        if ($trim.Length -eq 0) {
            continue
        }
        if ($trim -notmatch '^(?<hash>[0-9A-Fa-f]{64})\s+\*?(?<path>\S+)\s*$') {
            continue
        }
        $hash = $Matches['hash']
        $pathName = $Matches['path'] -replace '\\', '/'
        $file = $pathName.Substring($pathName.LastIndexOf('/') + 1)
        if ($file -eq $AssetName) {
            return $hash.ToUpperInvariant()
        }
    }

    throw "checksums.txt has no SHA256 for $AssetName. Refusing to invent one."
}

$raw = Get-Content -LiteralPath $ChecksumsPath
$lines = @()
if ($null -ne $raw) {
    $lines = @($raw)
}

function Try-ChecksumSha256 {
    param(
        [Parameter(Mandatory = $true)]
        [string]$AssetName,
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [string[]]$Lines
    )
    try {
        return Get-ChecksumSha256 -AssetName $AssetName -Lines $Lines
    }
    catch {
        return $null
    }
}

$amd64Sha = Try-ChecksumSha256 -AssetName 'cliamp-windows-amd64.zip' -Lines $lines
$arm64Sha = Try-ChecksumSha256 -AssetName 'cliamp-windows-arm64.zip' -Lines $lines
if ((-not $amd64Sha) -and (-not $arm64Sha)) {
    throw "checksums.txt has no SHA256 for cliamp-windows-amd64.zip or cliamp-windows-arm64.zip. Refusing to invent one."
}

function ConvertTo-InstallerUrl {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Value
    )
    if ($Value -match '^(https?|file):') {
        return $Value
    }
    if (-not (Test-Path -LiteralPath $Value)) {
        throw "Installer file not found: $Value"
    }
    $full = (Resolve-Path -LiteralPath $Value).Path
    return ([System.Uri]$full).AbsoluteUri
}

$baseUrl = "https://github.com/$Owner/$Repo"
$amd64Url = "$baseUrl/releases/download/$Tag/cliamp-windows-amd64.zip"
$arm64Url = "$baseUrl/releases/download/$Tag/cliamp-windows-arm64.zip"
if (-not [string]::IsNullOrWhiteSpace($Amd64InstallerUrl)) {
    $amd64Url = ConvertTo-InstallerUrl -Value $Amd64InstallerUrl
}
if (-not [string]::IsNullOrWhiteSpace($Arm64InstallerUrl)) {
    $arm64Url = ConvertTo-InstallerUrl -Value $Arm64InstallerUrl
}

$versionYaml = @"
# yaml-language-server: `$schema=https://aka.ms/winget-manifest.version.1.10.0.schema.json
PackageIdentifier: $PackageIdentifier
PackageVersion: $Version
DefaultLocale: en-US
ManifestType: version
ManifestVersion: 1.10.0
"@

$localeYaml = @"
# yaml-language-server: `$schema=https://aka.ms/winget-manifest.defaultLocale.1.10.0.schema.json
PackageIdentifier: $PackageIdentifier
PackageVersion: $Version
PackageLocale: en-US
Publisher: $Owner
PublisherUrl: https://github.com/$Owner
PackageName: cliamp
PackageUrl: $baseUrl
License: MIT
LicenseUrl: $baseUrl/blob/HEAD/LICENSE
ShortDescription: A retro terminal music player inspired by Winamp
Moniker: cliamp
ManifestType: defaultLocale
ManifestVersion: 1.10.0
"@

$nl = "`n"
$installerLines = @(
    '# yaml-language-server: $schema=https://aka.ms/winget-manifest.installer.1.10.0.schema.json'
    "PackageIdentifier: $PackageIdentifier"
    "PackageVersion: $Version"
    'InstallerType: zip'
    'NestedInstallerType: portable'
    'Installers:'
)
if ($amd64Sha) {
    $installerLines += @(
        '- Architecture: x64'
        '  NestedInstallerFiles:'
        '  - RelativeFilePath: cliamp-windows-amd64\cliamp.exe'
        '    PortableCommandAlias: cliamp'
        "  InstallerUrl: $amd64Url"
        "  InstallerSha256: $amd64Sha"
    )
}
if ($arm64Sha) {
    $installerLines += @(
        '- Architecture: arm64'
        '  NestedInstallerFiles:'
        '  - RelativeFilePath: cliamp-windows-arm64\cliamp.exe'
        '    PortableCommandAlias: cliamp'
        "  InstallerUrl: $arm64Url"
        "  InstallerSha256: $arm64Sha"
    )
}
$installerLines += @(
    'ManifestType: installer'
    'ManifestVersion: 1.10.0'
)
$installerYaml = ($installerLines -join $nl) + $nl

if (-not (Test-Path -LiteralPath $OutDir)) {
    New-Item -ItemType Directory -Path $OutDir | Out-Null
}

$utf8 = New-Object System.Text.UTF8Encoding $false
$files = @{
    "$PackageIdentifier.yaml"              = $versionYaml
    "$PackageIdentifier.installer.yaml"    = $installerYaml
    "$PackageIdentifier.locale.en-US.yaml" = $localeYaml
}

foreach ($name in $files.Keys) {
    $path = Join-Path -Path $OutDir -ChildPath $name
    $text = ($files[$name] -replace "`r`n", "`n").Trim() + "`n"
    [System.IO.File]::WriteAllText($path, $text, $utf8)
}

Write-Host "Wrote winget manifests to $OutDir using SHA256 from $ChecksumsPath"

#Requires -Version 7.4

<#
.SYNOPSIS
    Writes a self-contained HTML report of one or two toolkit exports, using
    the VI Export Viewer.

.DESCRIPTION
    Embeds the given export files (VIFolderManager or VITagManager JSON) in
    a copy of viewer.html and writes it as one HTML file. Open it in any
    browser, also offline: nothing is loaded from the internet and nothing
    is uploaded.

    One file gives an overview of that export. Two files of the same toolkit
    open in compare mode: the older export is the source, the newer one the
    target (the Swap button turns it round).

    The report holds the full export, including names from the environment
    it came from. Keep it where you keep the export files.

.PARAMETER Path
    One or two export files (.json).

.PARAMETER OutFile
    The HTML file to write. Defaults to Report_<first export name>.html
    next to the first export.

.PARAMETER ViewerPath
    The viewer to embed into. Defaults to viewer.html next to this script.

.EXAMPLE
    # Overview of one export
    .\New-VIExportReport.ps1 -Path .\Backups\Tags_vc01_Definitions_2026-11-16_10-00-00.json

.EXAMPLE
    # Compare report: source export and target export in one file
    .\New-VIExportReport.ps1 -Path .\src\Folders_DC1_2026-11-16_10-00-00.json, .\dst\Folders_DC1_2026-11-17_10-00-00.json -OutFile .\folders-compare.html

.NOTES
    Script   : New-VIExportReport.ps1
    Version  : 0.1.0
    Author   : Paul van Dieen
    Blog     : https://www.hollebollevsan.nl
    Requires : PowerShell 7.4+
    Tested   : Lab exports of VIFolderManager 1.2.0 and VITagManager 0.1.0,
               2026-11-16
#>

<#
CHANGELOG
    v0.1.0  2026-11-16  Paul van Dieen
        - Initial version: embeds one or two exports in viewer.html
#>

param(
    [Parameter(Mandatory = $true)]
    [ValidateCount(1, 2)]
    [string[]]$Path,

    [Parameter(Mandatory = $false)]
    [string]$OutFile = '',

    [Parameter(Mandatory = $false)]
    [string]$ViewerPath = ''
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$scriptVersion = '0.1.0'
$scriptAuthor  = 'Paul van Dieen'
$scriptBlogUrl = 'https://www.hollebollevsan.nl'
$scriptDir     = if ($PSScriptRoot) { $PSScriptRoot } else { (Get-Location).Path }

Write-Host ('=' * 62) -ForegroundColor DarkCyan
Write-Host ('  New-VIExportReport.ps1' + (' ' * 23) + "v$scriptVersion") -ForegroundColor Cyan
Write-Host "  Author : $scriptAuthor"  -ForegroundColor Cyan
Write-Host "  Blog   : $scriptBlogUrl" -ForegroundColor DarkGray
Write-Host ('=' * 62) -ForegroundColor DarkCyan

if (-not $ViewerPath) { $ViewerPath = Join-Path $scriptDir 'viewer.html' }

function ConvertTo-EmbeddedReport {
    # Puts export files into the viewer's <script id="vi-embedded"> block.
    # The files are embedded as they are (no re-serialising, so no depth or
    # date conversions); '<' is escaped so no export text can close the
    # script element.
    param([string[]]$JsonPath, [string]$Viewer)
    $marker = '<script type="application/json" id="vi-embedded">[]</script>'
    $html = Get-Content -Path $Viewer -Raw -Encoding UTF8
    if (-not $html.Contains($marker)) { throw "The viewer '$Viewer' has no embed block; use viewer.html 0.1.0 or later." }
    $items = foreach ($p in $JsonPath) {
        $raw = (Get-Content -Path $p -Raw -Encoding UTF8).TrimStart([char]0xFEFF)
        $null = $raw | ConvertFrom-Json   # stop on a file that isn't JSON
        '{"fileName":' + (ConvertTo-Json -InputObject (Split-Path $p -Leaf) -Compress) + ',"data":' + $raw + '}'
    }
    $json = ('[' + ($items -join ',') + ']').Replace('<', '<')
    return $html.Replace($marker, '<script type="application/json" id="vi-embedded">' + $json + '</script>')
}

foreach ($p in $Path) {
    if (-not (Test-Path -Path $p -PathType Leaf)) { Write-Host "  [ERROR] Not found: $p" -ForegroundColor Red; exit 1 }
}
if (-not (Test-Path -Path $ViewerPath -PathType Leaf)) { Write-Host "  [ERROR] Viewer not found: $ViewerPath" -ForegroundColor Red; exit 1 }

if (-not $OutFile) {
    $first = Get-Item -Path $Path[0]
    $OutFile = Join-Path $first.DirectoryName ('Report_' + $first.BaseName + '.html')
}

try {
    $html = ConvertTo-EmbeddedReport -JsonPath $Path -Viewer $ViewerPath
    Set-Content -Path $OutFile -Value $html -Encoding UTF8 -NoNewline
    Write-Host "  [OK]   Report written: $OutFile" -ForegroundColor Green
    if ($Path.Count -eq 2) { Write-Host '         Opens in compare mode (older export = source).' -ForegroundColor DarkGray }
    Write-Host '         It holds the full export; keep it with the export files.' -ForegroundColor DarkGray
}
catch {
    Write-Host "  [ERROR] $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

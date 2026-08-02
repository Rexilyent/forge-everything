<#
.SYNOPSIS
    Lists every file actually present in the modpack instance, organized by type,
    as a lightweight double-check against what links_to_mods.txt / the processing
    report say should be there.

.DESCRIPTION
    No hashing, no API calls - just a fast directory listing across whichever
    instance folders you point it at (mods, resourcepacks, shaderpacks, datapacks,
    plugins). Useful as a quick sanity reference: eyeball it directly, grep it for
    a specific mod, or diff it against mod-list-processing-report.csv's Filename
    column to spot anything unaccounted for at a glance.

    Only scans folders you actually provide a path for - all parameters are
    optional except at least one of them being set.

.PARAMETER InstanceModsFolder
    Path to the mods folder (scanned for *.jar)

.PARAMETER InstanceResourcepacksFolder
    Path to the resourcepacks folder (scanned for *.zip)

.PARAMETER InstanceShaderpacksFolder
    Path to the shaderpacks folder (scanned for *.zip)

.PARAMETER InstanceDatapacksFolder
    Path to wherever your datapack-loader expects zips (scanned for *.zip)

.PARAMETER InstancePluginsFolder
    Path to a plugins folder, if applicable (scanned for *.jar)

.PARAMETER OutputCsv
    Where to write the results. Default: instance-file-list.csv in the current dir.

.EXAMPLE
    .\Get-InstanceFileList.ps1 -InstanceModsFolder "C:\...\mods" -InstanceResourcepacksFolder "C:\...\resourcepacks"
#>

param(
    [string]$InstanceModsFolder,
    [string]$InstanceResourcepacksFolder,
    [string]$InstanceShaderpacksFolder,
    [string]$InstanceDatapacksFolder,
    [string]$InstancePluginsFolder,

    [string]$OutputCsv = ".\instance-file-list.csv"
)

$folders = @(
    @{ Type = "mod";          Path = $InstanceModsFolder;          Ext = "*.jar" }
    @{ Type = "resourcepack"; Path = $InstanceResourcepacksFolder; Ext = "*.zip" }
    @{ Type = "shader";       Path = $InstanceShaderpacksFolder;   Ext = "*.zip" }
    @{ Type = "datapack";     Path = $InstanceDatapacksFolder;     Ext = "*.zip" }
    @{ Type = "plugin";       Path = $InstancePluginsFolder;       Ext = "*.jar" }
)

$configured = $folders | Where-Object { $_.Path }
if ($configured.Count -eq 0) {
    Write-Error "No folders provided - specify at least one -Instance...Folder parameter."
    exit 1
}

$results = New-Object System.Collections.Generic.List[object]

foreach ($f in $configured) {
    if (-not (Test-Path $f.Path)) {
        Write-Host "Warning: $($f.Type) folder not found: $($f.Path)" -ForegroundColor Yellow
        continue
    }
    $files = Get-ChildItem -Path $f.Path -Filter $f.Ext -File
    Write-Host "$($f.Type): $($files.Count) file(s) in $($f.Path)" -ForegroundColor Cyan
    foreach ($file in $files) {
        $results.Add([PSCustomObject]@{
            Type = $f.Type; Filename = $file.Name; SizeBytes = $file.Length; FullPath = $file.FullName
        })
    }
}

$results = $results | Sort-Object Type, Filename
$results | Export-Csv -Path $OutputCsv -NoTypeInformation

Write-Host "`n$($results.Count) files total -> $OutputCsv" -ForegroundColor Cyan

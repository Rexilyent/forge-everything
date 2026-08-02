<#
.SYNOPSIS
    Inventories every jar in a mods folder: filename, size, SHA1/SHA256 hash, and (where
    extractable) the mod's own modId + version from its embedded metadata.

.DESCRIPTION
    For each .jar in -ModsFolder:
      - Computes SHA1 and SHA256 (SHA1 matches Modrinth's version-file hash field directly;
        SHA256 is included as a stronger secondary check).
      - Opens the jar as a zip and looks for META-INF/neoforge.mods.toml, falling back to
        META-INF/mods.toml (older/forge-compat jars), and pulls the first [[mods]] block's
        modId and version.
      - If version is a placeholder like ${file.jarVersion}, falls back to reading
        Implementation-Version out of META-INF/MANIFEST.MF instead.
      - Jars with neither file (pure libraries, some datapack-only jars) are still recorded
        with blank ModId/Version and a note, rather than skipped - you still want the hash.

    This is a read-only inventory pass. It does not touch the links list or the resolved
    list - that cross-referencing is the next script, which will join on ModId/slug and
    compare Version against what's in links_to_mods.resolved.txt.

.PARAMETER ModsFolder
    Path to the folder containing your .jar files (e.g. the instance's \mods folder)

.PARAMETER OutputCsv
    Where to write the inventory. Default: mod-folder-inventory.csv in the current directory.

.PARAMETER Recurse
    Also scan subfolders (useful if you keep client-only/server-only jars split out).

.EXAMPLE
    .\Get-ModFolderInventory.ps1 -ModsFolder "C:\Users\Terra\AppData\Roaming\ModrinthApp\profiles\NeoForge 1.21.1\mods"
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$ModsFolder,

    [string]$OutputCsv = ".\mod-folder-inventory.csv",

    [switch]$Recurse,

    [string]$ModpackVersion,
    [string]$SecretsFile = (Join-Path $PSScriptRoot "secrets.local.env")
)

if (-not (Test-Path $ModsFolder)) {
    Write-Error "Mods folder not found: $ModsFolder"
    exit 1
}

# MODPACK_VERSION is a manually-bumped value YOU control (in secrets.local.env or via
# -ModpackVersion) - not a timestamp. Bump it any time you change the mods folder in a
# way that matters (add/update/remove a mod). This gets stamped into the inventory so
# consumers (Process-ModList.ps1) can tell at a glance whether the inventory still
# reflects the current state of the pack, or needs regenerating.
if (-not $ModpackVersion -and (Test-Path $SecretsFile)) {
    foreach ($line in Get-Content -Path $SecretsFile) {
        $line = $line.Trim()
        if (-not $line -or $line.StartsWith("#")) { continue }
        $idx = $line.IndexOf("=")
        if ($idx -lt 1) { continue }
        if ($line.Substring(0, $idx).Trim() -eq "MODPACK_VERSION") {
            $ModpackVersion = $line.Substring($idx + 1).Trim().Trim('"').Trim("'")
        }
    }
}
if (-not $ModpackVersion) {
    Write-Host "No MODPACK_VERSION found (param or secrets.local.env) - stamping inventory as 'unversioned'" -ForegroundColor Yellow
    Write-Host "Add 'MODPACK_VERSION=<something>' to $SecretsFile and bump it whenever the pack changes, for reliable freshness checks." -ForegroundColor Yellow
    $ModpackVersion = "unversioned"
}
else {
    Write-Host "Modpack version: $ModpackVersion" -ForegroundColor Cyan
}

Add-Type -AssemblyName System.IO.Compression.FileSystem

function Get-TomlValue {
    param([string]$TomlText, [string]$Key)
    # Matches: key = "value"  or key="value"  (first occurrence only)
    $m = [regex]::Match($TomlText, "(?m)^\s*$Key\s*=\s*`"([^`"]*)`"")
    if ($m.Success) { return $m.Groups[1].Value }
    return $null
}

function Get-JarModInfo {
    param([string]$JarPath)

    $result = [PSCustomObject]@{
        ModId  = $null
        Version = $null
        Note    = $null
    }

    try {
        $zip = [System.IO.Compression.ZipFile]::OpenRead($JarPath)
    }
    catch {
        $result.Note = "could not open as zip: $($_.Exception.Message)"
        return $result
    }

    try {
        $tomlEntry = $zip.Entries | Where-Object { $_.FullName -eq "META-INF/neoforge.mods.toml" } | Select-Object -First 1
        if (-not $tomlEntry) {
            $tomlEntry = $zip.Entries | Where-Object { $_.FullName -eq "META-INF/mods.toml" } | Select-Object -First 1
        }

        if (-not $tomlEntry) {
            $result.Note = "no mods.toml found (library jar or non-standard packaging)"
            return $result
        }

        $reader = New-Object System.IO.StreamReader($tomlEntry.Open())
        $tomlText = $reader.ReadToEnd()
        $reader.Close()

        $modId = Get-TomlValue -TomlText $tomlText -Key "modId"
        $version = Get-TomlValue -TomlText $tomlText -Key "version"

        if ($version -and $version -match '\$\{.*\}') {
            # Placeholder like ${file.jarVersion} - pull the real value from the manifest instead
            $manifestEntry = $zip.Entries | Where-Object { $_.FullName -eq "META-INF/MANIFEST.MF" } | Select-Object -First 1
            if ($manifestEntry) {
                $mReader = New-Object System.IO.StreamReader($manifestEntry.Open())
                $manifestText = $mReader.ReadToEnd()
                $mReader.Close()
                $mMatch = [regex]::Match($manifestText, "(?m)^Implementation-Version:\s*(.+)\s*$")
                if ($mMatch.Success) {
                    $version = $mMatch.Groups[1].Value.Trim()
                }
                else {
                    $result.Note = "version placeholder unresolved (no Implementation-Version in manifest)"
                }
            }
        }

        $result.ModId = $modId
        $result.Version = $version
    }
    finally {
        $zip.Dispose()
    }

    return $result
}

$jarFiles = if ($Recurse) {
    Get-ChildItem -Path $ModsFolder -Filter "*.jar" -Recurse -File
} else {
    Get-ChildItem -Path $ModsFolder -Filter "*.jar" -File
}

Write-Host "Found $($jarFiles.Count) jar files in $ModsFolder" -ForegroundColor Cyan

$inventory = New-Object System.Collections.Generic.List[object]
$i = 0

foreach ($jar in $jarFiles) {
    $i++
    Write-Host "[$i/$($jarFiles.Count)] $($jar.Name)" -ForegroundColor Green

    $sha1 = $null
    $sha256 = $null
    $hashNote = $null
    try {
        $sha1 = (Get-FileHash -LiteralPath $jar.FullName -Algorithm SHA1).Hash
        $sha256 = (Get-FileHash -LiteralPath $jar.FullName -Algorithm SHA256).Hash
    }
    catch {
        $hashNote = "hashing failed: $($_.Exception.Message)"
        Write-Host "  WARNING: hash failed for $($jar.Name) - $($_.Exception.Message)" -ForegroundColor Red
    }
    $modInfo = Get-JarModInfo -JarPath $jar.FullName
    $noteParts = @($hashNote, $modInfo.Note) | Where-Object { $_ }
    $combinedNote = $noteParts -join "; "

    $inventory.Add([PSCustomObject]@{
        FileName        = $jar.Name
        FullPath        = $jar.FullName
        SizeBytes       = $jar.Length
        LastWriteTimeUtc = $jar.LastWriteTimeUtc.ToString("o")
        SHA1            = $sha1
        SHA256          = $sha256
        ModId           = $modInfo.ModId
        Version         = $modInfo.Version
        Note            = $combinedNote
    })
}

$inventory | Export-Csv -Path $OutputCsv -NoTypeInformation

# Sidecar metadata file - lets consumers (like Process-ModList.ps1) know how old this
# inventory is at a glance, without having to infer it from individual file timestamps.
$metaPath = [System.IO.Path]::ChangeExtension($OutputCsv, ".meta.json")
[PSCustomObject]@{
    GeneratedAtUtc = (Get-Date).ToUniversalTime().ToString("o")
    ModpackVersion = $ModpackVersion
    ModsFolder     = $ModsFolder
    FileCount      = $inventory.Count
} | ConvertTo-Json | Set-Content -Path $metaPath

$withModId = ($inventory | Where-Object { $_.ModId }).Count
$noModId = $inventory.Count - $withModId

Write-Host "`nWrote $($inventory.Count) entries to $OutputCsv" -ForegroundColor Cyan
Write-Host "Metadata (generation time) written to $metaPath" -ForegroundColor Cyan
Write-Host "$withModId jars had extractable modId/version, $noModId did not (see Note column)" -ForegroundColor Yellow

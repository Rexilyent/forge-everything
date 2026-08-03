<#
.SYNOPSIS
    Sets `side` in every .pw.toml using the working server's mods folder as the
    sole source of truth.

.DESCRIPTION
    The running server's mods folder is the only authoritative statement of what
    is server-relevant. It cannot disagree with the server that is actually
    working, which a hand-classified list eventually will.

    Default rules (server folder only):
      jar is on the server      -> both
      jar is not on the server  -> client

    The pack IS the client set, so absence from the server is the entire signal.
    No client folder is needed.

    -ClientModsFolder is optional and only adds one distinction: it lets a mod
    present on the server but absent from the client be marked `server` rather
    than `both`. Skip it unless you specifically want that.

    The run also reports jars present on the server that the pack has no entry
    for. Those are hand-maintained today and would be silently dropped the first
    time the server syncs from packwiz - EvoLoginTimeout and similar server-side
    utilities are the usual case.

    Loose .jar files in the pack (everythingores, everythingbugs, and the two
    self-hosted LGPL mods) have no metadata file and therefore no side field.
    They always go to both. They are reported, not modified.

    Defaults to a dry run. Nothing is written without -Apply.

.EXAMPLE
    .\Set-ModSides.ps1 -ServerModsFolder "\\SERVER\forge_everything\mods" -PackDir ".\packwiz"

.EXAMPLE
    .\Set-ModSides.ps1 -ServerFileList .\server-mods.txt -PackDir ".\packwiz" -Apply
#>

param(
    [string]$ServerModsFolder,
    [string]$ClientModsFolder,
    # Alternative to -ServerModsFolder: a text file with one jar filename per
    # line. Useful when the server is remote and you only have `ls` output.
    [string]$ServerFileList,

    [Parameter(Mandatory)][string]$PackDir,
    [switch]$Apply
)

function Get-JarNameSet {
    param([string]$Folder, [string]$ListFile)
    $set = @{}
    if ($ListFile) {
        if (-not (Test-Path $ListFile)) { throw "Server file list not found: $ListFile" }
        foreach ($line in Get-Content -LiteralPath $ListFile) {
            $n = $line.Trim()
            if ($n -and $n.ToLower().EndsWith(".jar")) { $set[$n] = $true }
        }
    }
    elseif ($Folder) {
        if (-not (Test-Path $Folder)) { throw "Folder not found: $Folder" }
        foreach ($f in Get-ChildItem -LiteralPath $Folder -Filter *.jar -File) { $set[$f.Name] = $true }
    }
    return $set
}

if (-not $ServerModsFolder -and -not $ServerFileList) {
    Write-Error "Provide -ServerModsFolder or -ServerFileList"; exit 1
}
$modsDir = Join-Path $PackDir "mods"
if (-not (Test-Path $modsDir)) { Write-Error "No mods folder under $PackDir"; exit 1 }

$serverSet = Get-JarNameSet -Folder $ServerModsFolder -ListFile $ServerFileList
Write-Host "Server jars: $($serverSet.Count)" -ForegroundColor Cyan

$clientSet = @{}
if ($ClientModsFolder) {
    $clientSet = Get-JarNameSet -Folder $ClientModsFolder
    Write-Host "Client jars: $($clientSet.Count)" -ForegroundColor Cyan
}

$changes = New-Object System.Collections.Generic.List[object]
$unchanged = 0
$looseJars = @(Get-ChildItem -LiteralPath $modsDir -Filter *.jar -File)
# Every jar the pack can deliver, by filename. Used at the end to find jars
# that exist on the server but are in no .pw.toml and no loose file - those
# are invisible to the pack and would disappear the moment the server starts
# syncing from packwiz instead of being maintained by hand.
$packKnows = @{}
foreach ($j in $looseJars) { $packKnows[$j.Name] = "loose jar" }

foreach ($toml in Get-ChildItem -LiteralPath $modsDir -Filter *.pw.toml -File) {
    $text = Get-Content -LiteralPath $toml.FullName -Raw

    $mFile = [regex]::Match($text, '(?m)^\s*filename\s*=\s*"([^"]+)"')
    if (-not $mFile.Success) {
        Write-Host "  no filename field, skipping: $($toml.Name)" -ForegroundColor Yellow
        continue
    }
    $jar = $mFile.Groups[1].Value
    $packKnows[$jar] = $toml.Name

    $mSide = [regex]::Match($text, '(?m)^\s*side\s*=\s*"([^"]*)"')
    $current = if ($mSide.Success) { $mSide.Groups[1].Value } else { "" }

    $onServer = $serverSet.ContainsKey($jar)
    # With no client list, treat every metadata entry as present on the client:
    # the pack IS the client set, so absence from the server is the only signal.
    $onClient = if ($clientSet.Count -gt 0) { $clientSet.ContainsKey($jar) } else { $true }

    $desired = if ($onServer -and $onClient) { "both" }
               elseif ($onClient)            { "client" }
               elseif ($onServer)            { "server" }
               else                          { $null }   # in neither: leave alone

    if (-not $desired) {
        Write-Host "  in neither client nor server, leaving as-is: $jar" -ForegroundColor Yellow
        continue
    }

    if ($desired -eq $current) { $unchanged++; continue }

    $changes.Add([PSCustomObject]@{
        File = $toml.Name; Jar = $jar; From = $(if ($current) { $current } else { "<unset>" }); To = $desired
        Path = $toml.FullName; Text = $text; HasSide = $mSide.Success
    })
}

Write-Host "`n--- Proposed changes ---" -ForegroundColor Cyan
foreach ($grp in ($changes | Group-Object To | Sort-Object Name)) {
    Write-Host "`n  -> side = `"$($grp.Name)`"  ($($grp.Count))" -ForegroundColor Green
    foreach ($c in ($grp.Group | Sort-Object Jar)) { Write-Host "       $($c.Jar)" -ForegroundColor DarkGray }
}
Write-Host "`n  unchanged: $unchanged" -ForegroundColor DarkGray

if ($looseJars.Count -gt 0) {
    Write-Host "`n  loose jars (always both, no side field possible):" -ForegroundColor Yellow
    foreach ($j in $looseJars) {
        $flag = if ($serverSet.ContainsKey($j.Name)) { "" } else { "  <-- NOT on your server; verify it is server-safe" }
        Write-Host "       $($j.Name)$flag" -ForegroundColor Yellow
    }
}

# The important check when the server folder is the sole source of truth: what
# is running on the server that the pack has never heard of? Those mods are
# currently kept alive by hand. Once the server syncs from packwiz they will be
# removed, and the failure will look like an unrelated regression.
$orphans = @($serverSet.Keys | Where-Object { -not $packKnows.ContainsKey($_) } | Sort-Object)
if ($orphans.Count -gt 0) {
    Write-Host "`n  ON YOUR SERVER BUT NOT IN THE PACK ($($orphans.Count)):" -ForegroundColor Red
    foreach ($o in $orphans) { Write-Host "       $o" -ForegroundColor Red }
    Write-Host "       These are hand-maintained on the server today. The pack cannot" -ForegroundColor Yellow
    Write-Host "       deliver them, so they will be lost when the server syncs from" -ForegroundColor Yellow
    Write-Host "       packwiz. Add each with 'packwiz mr add' / 'packwiz cf add' and" -ForegroundColor Yellow
    Write-Host "       set side = `"server`", or accept that they are going away." -ForegroundColor Yellow
} else {
    Write-Host "`n  every server jar is represented in the pack" -ForegroundColor Green
}

if (-not $Apply) {
    Write-Host "`nDry run. Re-run with -Apply to write these changes." -ForegroundColor Cyan
    exit 0
}

foreach ($c in $changes) {
    if ($c.HasSide) {
        $new = [regex]::Replace($c.Text, '(?m)^(\s*side\s*=\s*")[^"]*(")', "`${1}$($c.To)`${2}")
    } else {
        # Insert after filename so the field ordering matches everything else.
        # No trailing \s* - it is greedy across newlines and would swallow the
        # line break, leaving a stray blank line before the inserted field.
        $new = [regex]::Replace($c.Text, '(?m)^(\s*filename\s*=\s*"[^"]+")', "`$1`r`nside = `"$($c.To)`"", 1)
    }
    [System.IO.File]::WriteAllText($c.Path, $new, (New-Object System.Text.UTF8Encoding($false)))
}

Write-Host "`nUpdated $($changes.Count) file(s)." -ForegroundColor Green
Write-Host "Now run: packwiz refresh" -ForegroundColor Cyan

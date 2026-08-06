<#
.SYNOPSIS
    Triages a Forge Everything tag_audit export into tags that are ACTUALLY broken
    ("cooked") versus scanner blind spots and harmless optional noise.

.DESCRIPTION
    The static tag audit reports ~800 dangling refs and ~6200 unknown-namespace
    entries. The overwhelming majority are NOT breakage:

      * The audit scans the mods folder only. It never sees the vanilla client jar
        or the NeoForge jar, so every reference to a built-in tag (c:ingots/gold,
        minecraft:jungle_logs, c:obsidians ...) is reported as dangling even though
        it resolves perfectly at runtime. These are SUSPECT, not cooked.
      * Optional entries (Required=False, reported as Severity "soft") are designed
        to silently vanish when the target mod is absent. That is working as intended.

    This script cross-references the audit against the mod IDs that actually loaded
    (parsed from the client log's "Mod List:" block) and assigns each finding a
    verdict:

      COOKED   Confirmed breakage. Required reference into a namespace that IS
               loaded, but nothing declares the target tag. The mod is shipping a
               broken self-reference or expects a different version of a sibling mod.
               Also: parse errors, and replace=true declared by 2+ sources.
      DEAD     Required reference into a mod that is not installed. Broken, but the
               fix is "install the mod" or "patch it out", not "the tag is wrong".
      SUSPECT  Required reference into c:/minecraft:/neoforge:/forge:. Cannot be
               resolved statically. Supply -BuiltinTagIndex to auto-resolve these.
      NOISE    Optional / soft findings. Reported only with -IncludeNoise.

.PARAMETER AuditDir
    Folder containing the tag audit CSVs (dangling_tag_refs.csv, tags_merged.csv,
    unknown_namespace_entries.csv, declaring_conflicts.csv, parse_errors.csv).

.PARAMETER LogPath
    Path to latest.log (or any client log containing the "Mod List:" block).

.PARAMETER BuiltinTagIndex
    Optional. Text file, one tag ID per line, listing every tag that exists at
    runtime. Generate with ProbeJS (/probejs dump, then read kubejs/probe/) or a
    KubeJS script. When supplied, SUSPECT findings are resolved into COOKED or
    dropped, which is the only way to get a fully trustworthy result.

.PARAMETER OutDir
    Where to write reports. Defaults to <AuditDir>\cooked.

.PARAMETER IncludeNoise
    Also emit noise_tags.csv with the soft/optional findings.

.EXAMPLE
    .\Get-CookedTags.ps1 -AuditDir .\tag_audit -LogPath .\logs\latest.log

.EXAMPLE
    .\Get-CookedTags.ps1 -AuditDir .\tag_audit -LogPath .\logs\latest.log `
        -BuiltinTagIndex .\runtime_tags.txt -IncludeNoise

.NOTES
    PowerShell 5.1 compatible. No ConvertFrom-Json -AsHashtable, no Set-Content,
    -LiteralPath everywhere (mod jars have [bracket] filenames).
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string] $AuditDir,

    [Parameter(Mandatory = $true)]
    [string] $LogPath,

    [string] $BuiltinTagIndex,

    [string] $OutDir,

    [switch] $IncludeNoise
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2.0

# Namespaces provided by the game/loader itself, which the mods-folder scan
# cannot see. Anything dangling into these is unverifiable without a runtime dump.
$script:BuiltinNamespaces = @('minecraft', 'c', 'neoforge', 'forge', 'fabric')

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

function Resolve-InputPath {
    param([string] $Path, [string] $Label)
    if ([string]::IsNullOrWhiteSpace($Path)) {
        throw "$Label was not supplied."
    }
    if (-not (Test-Path -LiteralPath $Path)) {
        throw "$Label not found: $Path"
    }
    return (Resolve-Path -LiteralPath $Path).ProviderPath
}

function Write-TextFile {
    param([string] $Path, [string] $Content)
    # Set-Content can fail silently on long content; go through .NET directly.
    $dir = Split-Path -LiteralPath $Path -Parent
    if ($dir -and -not (Test-Path -LiteralPath $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    [System.IO.File]::WriteAllText($Path, $Content, (New-Object System.Text.UTF8Encoding($false)))
}

function Get-TagNamespace {
    param([string] $TagId)
    if ([string]::IsNullOrWhiteSpace($TagId)) { return 'minecraft' }
    $i = $TagId.IndexOf(':')
    if ($i -lt 1) { return 'minecraft' }   # bare paths default to minecraft
    return $TagId.Substring(0, $i)
}

function Import-AuditCsv {
    param([string] $Dir, [string] $Name, [switch] $Optional)
    $path = Join-Path $Dir $Name
    if (-not (Test-Path -LiteralPath $path)) {
        if ($Optional) {
            Write-Verbose "Optional audit file missing, skipping: $Name"
            return @()
        }
        throw "Required audit file missing: $path"
    }
    $rows = @(Import-Csv -LiteralPath $path)
    Write-Verbose ("{0,-32} {1,7} rows" -f $Name, $rows.Count)
    return $rows
}

# ---------------------------------------------------------------------------
# Step 1 - parse loaded mod IDs out of the client log
# ---------------------------------------------------------------------------

function Get-LoadedModIds {
    param([string] $LogFile)

    $ids = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
    $inList = $false
    $sinceList = 0

    $reader = New-Object System.IO.StreamReader($LogFile)
    try {
        while ($null -ne ($line = $reader.ReadLine())) {
            if (-not $inList) {
                if ($line -match 'Mod List:') { $inList = $true }
                continue
            }

            $sinceList++
            # Entries look like:  <tab><tab>Advanced AE 1.6.11-1.21.1 (advanced_ae)
            if ($line -match '\(([a-z0-9_\-\.]+)\)\s*$') {
                [void]$ids.Add($matches[1])
                $sinceList = 0
                continue
            }

            # Blank lines and the "Name Version (Mod Id)" header are tolerated;
            # a run of real content means the block has ended.
            if ($line.Trim().Length -gt 0 -and $sinceList -gt 3) { break }
        }
    }
    finally {
        $reader.Dispose()
    }

    if ($ids.Count -eq 0) {
        throw "No 'Mod List:' block found in $LogFile - is this a client log from a completed launch?"
    }
    return $ids
}

# ---------------------------------------------------------------------------
# Step 2 - build the set of tags the pack actually declares
# ---------------------------------------------------------------------------

function Get-DeclaredTagSet {
    param([object[]] $MergedRows)
    $set = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
    foreach ($r in $MergedRows) { [void]$set.Add($r.TagId) }
    return $set
}

function Get-BuiltinTagSet {
    param([string] $IndexPath)
    if ([string]::IsNullOrWhiteSpace($IndexPath)) { return $null }
    $p = Resolve-InputPath -Path $IndexPath -Label 'BuiltinTagIndex'
    $set = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
    foreach ($line in [System.IO.File]::ReadLines($p)) {
        $t = $line.Trim().TrimStart('#')
        if ($t.Length -gt 0 -and -not $t.StartsWith('//')) { [void]$set.Add($t) }
    }
    Write-Verbose ("BuiltinTagIndex loaded: {0} tags" -f $set.Count)
    return $set
}

# ---------------------------------------------------------------------------
# Step 3 - classification
# ---------------------------------------------------------------------------

function New-Finding {
    param(
        [string] $Verdict, [int] $Score, [string] $Kind, [string] $TagId,
        [string] $Registry, [string] $Problem, [string] $Detail,
        [string] $Source, [string] $File, [string] $Fix
    )
    return [pscustomobject][ordered]@{
        Verdict  = $Verdict
        Score    = $Score
        Kind     = $Kind
        TagId    = $TagId
        Registry = $Registry
        Problem  = $Problem
        Detail   = $Detail
        Source   = $Source
        File     = $File
        Fix      = $Fix
    }
}

function Invoke-DanglingTriage {
    param(
        [object[]] $Rows,
        [System.Collections.Generic.HashSet[string]] $LoadedMods,
        [System.Collections.Generic.HashSet[string]] $BuiltinTags
    )

    $out = New-Object System.Collections.ArrayList
    foreach ($r in $Rows) {
        $isHard  = ($r.Severity -eq 'HARD')
        $missing = $r.MissingTag
        $ns      = Get-TagNamespace $missing

        # If we have a runtime index, it is authoritative - resolve first.
        if ($null -ne $BuiltinTags -and $BuiltinTags.Contains($missing)) { continue }

        $isBuiltinNs = ($script:BuiltinNamespaces -contains $ns)
        $modLoaded   = $LoadedMods.Contains($ns)

        if ($isBuiltinNs -and $null -eq $BuiltinTags) {
            $verdict = 'SUSPECT'
            $score   = 40
            $fix     = "Supply -BuiltinTagIndex to confirm. '$ns' tags ship with the game/loader and are invisible to a mods-folder scan."
        }
        elseif ($modLoaded -or ($isBuiltinNs -and $null -ne $BuiltinTags)) {
            $verdict = 'COOKED'
            $score   = 100
            $fix     = "'$ns' is loaded but nothing declares '$missing'. Version mismatch or a shipped-broken self-reference. Declare it in forgeeverything_datapack."
        }
        else {
            $verdict = 'DEAD'
            $score   = 70
            $fix     = "Mod '$ns' is not installed. Install it, or stub '$missing' as an empty tag in forgeeverything_datapack to silence the error."
        }

        if (-not $isHard) {
            $verdict = 'NOISE'
            $score   = 10
            $fix     = 'Optional reference - vanishes cleanly when absent. No action needed.'
        }

        [void]$out.Add((New-Finding -Verdict $verdict -Score $score -Kind 'DanglingRef' `
            -TagId $r.ReferencingTag -Registry $r.Registry `
            -Problem 'References a tag that nothing declares' -Detail $missing `
            -Source $r.SourceName -File $r.File -Fix $fix))
    }
    return $out.ToArray()
}

function Invoke-UnknownNamespaceTriage {
    param(
        [object[]] $Rows,
        [System.Collections.Generic.HashSet[string]] $LoadedMods
    )

    $out = New-Object System.Collections.ArrayList
    foreach ($r in $Rows) {
        $isHard   = ($r.Severity -eq 'HARD')
        $modLoaded = $LoadedMods.Contains($r.EntryNs)

        if (-not $isHard) {
            $verdict = 'NOISE'; $score = 10
            $fix = 'Optional entry - dropped silently when the mod is absent. No action needed.'
        }
        elseif ($modLoaded) {
            $verdict = 'COOKED'; $score = 100
            $fix = "'$($r.EntryNs)' is loaded but does not register '$($r.EntryId)'. Version mismatch - check the mod version against what the declaring mod expects."
        }
        else {
            $verdict = 'DEAD'; $score = 90
            $fix = "Required entry from absent mod '$($r.EntryNs)'. This tag will fail to load. Patch the entry to optional (prefix with '#'-style optional syntax) via forgeeverything_datapack, or install the mod."
        }

        [void]$out.Add((New-Finding -Verdict $verdict -Score $score -Kind 'UnknownNamespace' `
            -TagId $r.TagId -Registry $r.Registry `
            -Problem 'Required entry from an unrecognised namespace' -Detail $r.EntryId `
            -Source $r.SourceName -File $r.File -Fix $fix))
    }
    return $out.ToArray()
}

function Invoke-ConflictTriage {
    param([object[]] $Rows)

    $out = New-Object System.Collections.ArrayList
    foreach ($r in $Rows) {
        $hasReplace = ($r.HasReplace -eq 'True')
        $declCount  = 0
        [void][int]::TryParse($r.DeclaringCount, [ref]$declCount)

        if ($hasReplace -and $declCount -gt 1) {
            # One source is wiping the other's entries depending on load order.
            [void]$out.Add((New-Finding -Verdict 'COOKED' -Score 95 -Kind 'ReplaceConflict' `
                -TagId $r.TagId -Registry $r.Registry `
                -Problem "replace=true with $declCount declaring sources" -Detail $r.DeclaredBy `
                -Source $r.DeclaredBy -File '' `
                -Fix 'Load order decides which mod wins and the loser''s entries are silently discarded. Re-declare the union in forgeeverything_datapack with replace=false.'))
        }
        elseif ($r.LegacyDirUsed -eq 'True' -and $declCount -gt 1) {
            # Mixed tags/items vs tags/item across sources on the same tag.
            [void]$out.Add((New-Finding -Verdict 'SUSPECT' -Score 35 -Kind 'LegacyDir' `
                -TagId $r.TagId -Registry $r.Registry `
                -Problem 'Mixed legacy plural / singular tag directories' -Detail $r.DeclaredBy `
                -Source $r.DeclaredBy -File '' `
                -Fix 'Verify both halves merge at runtime. 1.21.1 expects singular dirs (tags/item); NeoForge still maps the plural form, but check the merged result in-game.'))
        }
    }
    return $out.ToArray()
}

function Invoke-ParseErrorTriage {
    param([object[]] $Rows)
    $out = New-Object System.Collections.ArrayList
    foreach ($r in $Rows) {
        [void]$out.Add((New-Finding -Verdict 'COOKED' -Score 100 -Kind 'ParseError' `
            -TagId $r.TagId -Registry '' `
            -Problem 'Tag JSON failed to parse' -Detail $r.Error `
            -Source $r.SourceName -File $r.File `
            -Fix 'Malformed or empty tag file. Override it with a valid JSON file in forgeeverything_datapack.'))
    }
    return $out.ToArray()
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

$AuditDir = Resolve-InputPath -Path $AuditDir -Label 'AuditDir'
$LogPath  = Resolve-InputPath -Path $LogPath  -Label 'LogPath'

if ([string]::IsNullOrWhiteSpace($OutDir)) {
    $OutDir = Join-Path $AuditDir 'cooked'
}
if (-not (Test-Path -LiteralPath $OutDir)) {
    New-Item -ItemType Directory -Path $OutDir -Force | Out-Null
}

Write-Host "Parsing mod list from log..." -ForegroundColor Cyan
$loadedMods = Get-LoadedModIds -LogFile $LogPath
Write-Host ("  {0} mod IDs loaded at runtime" -f $loadedMods.Count)

$builtinTags = Get-BuiltinTagSet -IndexPath $BuiltinTagIndex
if ($null -eq $builtinTags) {
    Write-Host "  No -BuiltinTagIndex supplied: c:/minecraft:/neoforge: refs will be tiered SUSPECT." -ForegroundColor DarkYellow
}

Write-Host "Loading audit CSVs..." -ForegroundColor Cyan
$dangling  = Import-AuditCsv -Dir $AuditDir -Name 'dangling_tag_refs.csv'
$unknownNs = Import-AuditCsv -Dir $AuditDir -Name 'unknown_namespace_entries.csv'
$conflicts = Import-AuditCsv -Dir $AuditDir -Name 'declaring_conflicts.csv'
$parseErrs = Import-AuditCsv -Dir $AuditDir -Name 'parse_errors.csv' -Optional
$merged    = Import-AuditCsv -Dir $AuditDir -Name 'tags_merged.csv'   -Optional

$declared = Get-DeclaredTagSet -MergedRows $merged
Write-Host ("  {0} unique tag IDs declared by the pack" -f $declared.Count)

Write-Host "Triaging..." -ForegroundColor Cyan
$findings = New-Object System.Collections.ArrayList
foreach ($f in (Invoke-DanglingTriage         -Rows $dangling  -LoadedMods $loadedMods -BuiltinTags $builtinTags)) { [void]$findings.Add($f) }
foreach ($f in (Invoke-UnknownNamespaceTriage -Rows $unknownNs -LoadedMods $loadedMods))                          { [void]$findings.Add($f) }
foreach ($f in (Invoke-ConflictTriage         -Rows $conflicts))                                                  { [void]$findings.Add($f) }
foreach ($f in (Invoke-ParseErrorTriage       -Rows $parseErrs))                                                  { [void]$findings.Add($f) }

$all     = $findings.ToArray()
$cooked  = @($all | Where-Object { $_.Verdict -eq 'COOKED'  })
$dead    = @($all | Where-Object { $_.Verdict -eq 'DEAD'    })
$suspect = @($all | Where-Object { $_.Verdict -eq 'SUSPECT' })
$noise   = @($all | Where-Object { $_.Verdict -eq 'NOISE'   })

$actionable = @($cooked + $dead + $suspect | Sort-Object -Property @{E='Score';Descending=$true}, Kind, TagId)

# ---------------------------------------------------------------------------
# Output
# ---------------------------------------------------------------------------

$cookedCsv  = Join-Path $OutDir 'cooked_tags.csv'
$triageCsv  = Join-Path $OutDir 'tag_triage_all.csv'
$summaryTxt = Join-Path $OutDir 'cooked_summary.txt'

@($cooked | Sort-Object -Property @{E='Score';Descending=$true}, Kind, TagId) |
    Export-Csv -LiteralPath $cookedCsv -NoTypeInformation -Encoding UTF8
$actionable | Export-Csv -LiteralPath $triageCsv -NoTypeInformation -Encoding UTF8

if ($IncludeNoise) {
    $noiseCsv = Join-Path $OutDir 'noise_tags.csv'
    @($noise | Sort-Object Kind, TagId) | Export-Csv -LiteralPath $noiseCsv -NoTypeInformation -Encoding UTF8
}

$sb = New-Object System.Text.StringBuilder
[void]$sb.AppendLine("COOKED TAG TRIAGE - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')")
[void]$sb.AppendLine("Audit  : $AuditDir")
[void]$sb.AppendLine("Log    : $LogPath")
[void]$sb.AppendLine("Runtime: $($loadedMods.Count) mod IDs")
if ($null -ne $builtinTags) {
    [void]$sb.AppendLine("Builtin: $($builtinTags.Count) runtime tags (SUSPECT tier resolved)")
} else {
    [void]$sb.AppendLine("Builtin: not supplied - SUSPECT tier unresolved")
}
[void]$sb.AppendLine()
[void]$sb.AppendLine('VERDICTS')
[void]$sb.AppendLine(("  COOKED  (fix these)      : {0}" -f $cooked.Count))
[void]$sb.AppendLine(("  DEAD    (mod not present): {0}" -f $dead.Count))
[void]$sb.AppendLine(("  SUSPECT (needs runtime)  : {0}" -f $suspect.Count))
[void]$sb.AppendLine(("  NOISE   (ignore)         : {0}" -f $noise.Count))
[void]$sb.AppendLine()

[void]$sb.AppendLine('COOKED BY KIND')
foreach ($g in ($cooked | Group-Object Kind | Sort-Object Count -Descending)) {
    [void]$sb.AppendLine(("  {0,4}  {1}" -f $g.Count, $g.Name))
}
[void]$sb.AppendLine()

[void]$sb.AppendLine('COOKED BY OFFENDING JAR')
foreach ($g in ($cooked | Group-Object Source | Sort-Object Count -Descending | Select-Object -First 20)) {
    $name = $g.Name
    if ($name.Length -gt 60) { $name = $name.Substring(0, 57) + '...' }
    [void]$sb.AppendLine(("  {0,4}  {1}" -f $g.Count, $name))
}
[void]$sb.AppendLine()

[void]$sb.AppendLine('COOKED DETAIL')
foreach ($f in ($cooked | Sort-Object -Property @{E='Score';Descending=$true}, TagId)) {
    [void]$sb.AppendLine(("  [{0}] {1}" -f $f.Kind, $f.TagId))
    [void]$sb.AppendLine(("        -> {0}" -f $f.Detail))
    [void]$sb.AppendLine(("        src {0}" -f $f.Source))
}
[void]$sb.AppendLine()
[void]$sb.AppendLine('NOTE: SUSPECT findings are references into c:/minecraft:/neoforge:/forge:.')
[void]$sb.AppendLine('      The audit scans the mods folder only and cannot see game/loader tags,')
[void]$sb.AppendLine('      so these are almost always false positives. Re-run with')
[void]$sb.AppendLine('      -BuiltinTagIndex <runtime tag dump> to resolve them definitively.')

Write-TextFile -Path $summaryTxt -Content $sb.ToString()

Write-Host ''
Write-Host ("COOKED  : {0}" -f $cooked.Count)  -ForegroundColor Red
Write-Host ("DEAD    : {0}" -f $dead.Count)    -ForegroundColor Yellow
Write-Host ("SUSPECT : {0}" -f $suspect.Count) -ForegroundColor DarkYellow
Write-Host ("NOISE   : {0}" -f $noise.Count)   -ForegroundColor DarkGray
Write-Host ''
Write-Host "Wrote:" -ForegroundColor Green
Write-Host "  $cookedCsv"
Write-Host "  $triageCsv"
Write-Host "  $summaryTxt"

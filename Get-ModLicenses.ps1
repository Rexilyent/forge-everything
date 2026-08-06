<#
.SYNOPSIS
    Extracts license and attribution metadata from every mod jar, and optionally
    cross-checks it against Modrinth.

.DESCRIPTION
    Local pass (always runs):
        Reads META-INF/neoforge.mods.toml (falling back to META-INF/mods.toml,
        then fabric.mod.json) from each jar WITHOUT extracting it, and records the
        declared license, mod IDs, display name, version, authors and URLs. Also
        detects bundled LICENSE/COPYING/NOTICE files.

    Verification pass (-VerifyModrinth):
        Batch-resolves each jar's SHA1 via POST /v2/version_files, batch-fetches
        the parent projects via GET /v2/projects?ids=[...], normalizes both the
        jar license and the Modrinth license through the same bucketing, and
        compares them.

        Verdicts:
          Match           - jar and Modrinth agree exactly
          NEAR-MATCH      - same license, different spelling ("LGPL v3" vs LGPL-3.0-only)
          MISMATCH        - genuinely different licenses. Investigate.
          JarUndeclared   - jar had no license field; Modrinth's value is used
          ModrinthCustom  - LicenseRef-* / non-SPDX; read the linked terms
          NotOnModrinth   - CurseForge-only or unresolvable; jar is the only source

.PARAMETER ModsFolder
    Defaults to INSTANCE_MODS_FOLDER, else INSTANCE_ROOT\mods.

.PARAMETER OutCsv
    Defaults to MOD_LICENSES_CSV, else OUTPUT_DIR\mod-licenses.csv.

.PARAMETER LicenseTextDir
    Only used with -DumpLicenseFiles. Defaults to LICENSE_TEXT_DIR, else
    OUTPUT_DIR\license-texts.

.NOTES
    PS 5.1 compatible. Modrinth requests work unauthenticated; MODRINTH_TOKEN
    only raises the rate limit.

.EXAMPLE
    .\Get-ModLicenses.ps1

.EXAMPLE
    .\Get-ModLicenses.ps1 -VerifyModrinth -DumpLicenseFiles
#>
[CmdletBinding()]
param(
    [string]$ModsFolder,
    [string]$OutCsv,

    # Cross-check declared licenses against Modrinth
    [switch]$VerifyModrinth,

    # Also inspect jar-in-jar dependencies under META-INF/jarjar/
    [switch]$IncludeNested,

    # Write the full text of every bundled LICENSE file to $LicenseTextDir
    [switch]$DumpLicenseFiles,
    [string]$LicenseTextDir,

    # Skip SHA1 computation. Incompatible with -VerifyModrinth.
    [switch]$NoHash,

    [string]$SecretsFile,
    [string]$ModrinthToken,
    [string]$PackVersion,

    [string]$UserAgent = "ForgeEverything-licensing-audit/1.0 (+https://github.com/rexilyent/forge-everything)",
    [int]$BatchSize = 100,
    [int]$ThrottleMs = 250
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression.FileSystem

# ===========================================================================
# Configuration
# ===========================================================================

$scriptRoot = $PSScriptRoot
if (-not $scriptRoot) { $scriptRoot = (Get-Location).ProviderPath }

. (Join-Path $scriptRoot "PackConfig.ps1")
Initialize-PackConfig -SecretsFile $SecretsFile -ScriptRoot $scriptRoot

# Each guard exists because PowerShell cannot distinguish a parameter you typed
# from a default it filled in. Without ContainsKey, the env file would override
# the flag you just passed on the command line.
if (-not $PSBoundParameters.ContainsKey('ModsFolder')) {
    $ModsFolder = Get-PackFolderSetting -Name INSTANCE_MODS_FOLDER `
                                        -ParentName INSTANCE_ROOT -ChildFolder 'mods'
}
if (-not $PSBoundParameters.ContainsKey('OutCsv')) {
    $OutCsv = Get-PackOutputPath -Name MOD_LICENSES_CSV -DefaultFileName 'mod-licenses.csv'
}
if (-not $PSBoundParameters.ContainsKey('ModrinthToken')) {
    $ModrinthToken = Get-PackSetting -Name MODRINTH_TOKEN
}
if (-not $PSBoundParameters.ContainsKey('PackVersion')) {
    $PackVersion = Get-PackSetting -Name MODPACK_VERSION -Default 'unversioned'
}

# A token left at the template placeholder is worse than no token: it would be
# sent as a real Authorization header and get every request rejected.
if ($ModrinthToken -and $ModrinthToken -match '^replace-me$') {
    Write-Host "MODRINTH_TOKEN is still 'replace-me' - continuing unauthenticated." -ForegroundColor DarkGray
    $ModrinthToken = $null
}

# Only resolve (and therefore create) the dump folder when it will be written to.
if ($DumpLicenseFiles -and -not $PSBoundParameters.ContainsKey('LicenseTextDir')) {
    $LicenseTextDir = Get-PackOutputFolder -Name LICENSE_TEXT_DIR -DefaultFolderName 'license-texts'
}

if ($VerifyModrinth -and $NoHash) {
    Write-Warning "-VerifyModrinth needs SHA1s to resolve files. Ignoring -NoHash."
    $NoHash = $false
}

if (-not $ModsFolder) {
    throw "No mods folder configured. Set INSTANCE_ROOT or INSTANCE_MODS_FOLDER in secrets.local.env, or pass -ModsFolder."
}
if (-not (Test-Path -LiteralPath $ModsFolder)) {
    throw "Mods folder not found: $ModsFolder"
}

$summary = @{
    'Mods folder'   = $ModsFolder
    'Output CSV'    = $OutCsv
    'Pack version'  = $PackVersion
    'Verify'        = if ($VerifyModrinth) { "Modrinth" } else { "<jars only>" }
    'Modrinth auth' = if ($ModrinthToken) { "token loaded" } else { "unauthenticated" }
}
if ($DumpLicenseFiles) { $summary['License texts'] = $LicenseTextDir }
Show-PackConfigSummary -Values $summary -Title "Get-ModLicenses"

$ApiBase = 'https://api.modrinth.com/v2'

# ===========================================================================
# Helpers
# ===========================================================================

$TomlValuePattern = @'
(?m)^[ \t]*{0}[ \t]*=[ \t]*(?:"""(?<v>[\s\S]*?)"""|'''(?<v>[\s\S]*?)'''|"(?<v>[^"]*)"|'(?<v>[^']*)')
'@

function Get-TomlString {
    param([string]$Toml, [string]$Key)
    if ([string]::IsNullOrEmpty($Toml)) { return $null }
    $m = [regex]::Match($Toml, ($TomlValuePattern -f ([regex]::Escape($Key))))
    if ($m.Success) { return $m.Groups['v'].Value.Trim() }
    return $null
}

function Get-TomlStringAll {
    param([string]$Toml, [string]$Key)
    if ([string]::IsNullOrEmpty($Toml)) { return @() }
    $out = New-Object System.Collections.Generic.List[string]
    foreach ($m in [regex]::Matches($Toml, ($TomlValuePattern -f ([regex]::Escape($Key))))) {
        $val = $m.Groups['v'].Value.Trim()
        if ($val -and -not $out.Contains($val)) { [void]$out.Add($val) }
    }
    return $out.ToArray()
}

function Get-ZipEntryText {
    param($Archive, [string]$EntryName)
    $entry = $Archive.GetEntry($EntryName)
    if ($null -eq $entry) { return $null }
    $stream = $entry.Open()
    try {
        $reader = New-Object System.IO.StreamReader($stream, [System.Text.Encoding]::UTF8)
        try { return $reader.ReadToEnd() } finally { $reader.Dispose() }
    } finally { $stream.Dispose() }
}

# One normalizer, fed BOTH the free-text jar string and the Modrinth SPDX id,
# so the two sides land in comparable buckets.
function Get-LicenseCategory {
    param([string]$Raw)

    if ([string]::IsNullOrWhiteSpace($Raw)) { return @{ Norm = 'UNDECLARED'; Cat = 'Unknown' } }

    $s = $Raw.Trim()
    $c = ($s -replace '[^a-zA-Z0-9]', '').ToLowerInvariant()

    $map = @(
        @{ Match = '^(mit|mitlicense|themitlicense)';               Norm = 'MIT';               Cat = 'Permissive' },
        @{ Match = 'apache';                                        Norm = 'Apache-2.0';        Cat = 'Permissive' },
        @{ Match = '^(bsd|bsd2|bsd3|.*bsdlicense)';                 Norm = 'BSD';               Cat = 'Permissive' },
        @{ Match = '^(isc|unlicense|zlib|wtfpl|publicdomain|cc0)';  Norm = 'Public/Permissive'; Cat = 'Permissive' },
        @{ Match = 'lgpl';                                          Norm = 'LGPL';              Cat = 'Weak copyleft' },
        @{ Match = 'mpl|mozillapublic';                             Norm = 'MPL-2.0';           Cat = 'Weak copyleft' },
        @{ Match = 'agpl';                                          Norm = 'AGPL';              Cat = 'Strong copyleft' },
        @{ Match = '(?<!l)(?<!a)gpl';                               Norm = 'GPL';               Cat = 'Strong copyleft' },
        @{ Match = 'ccbyncsa|creativecommonsattributionnoncommercialsharealike'; Norm = 'CC BY-NC-SA'; Cat = 'CC (non-commercial)' },
        @{ Match = 'ccbync';                                        Norm = 'CC BY-NC';          Cat = 'CC (non-commercial)' },
        @{ Match = 'ccbysa';                                        Norm = 'CC BY-SA';          Cat = 'CC (share-alike)' },
        @{ Match = '^ccby';                                         Norm = 'CC BY';             Cat = 'CC (attribution)' },
        @{ Match = 'creativecommons|^cc';                           Norm = 'Creative Commons';  Cat = 'CC (other)' },
        @{ Match = 'allrightsreserved|^arr$|^arr[^a-z]|licenserefallrightsreserved'; Norm = 'All Rights Reserved'; Cat = 'ARR - check terms' },
        @{ Match = 'eupl';                                          Norm = 'EUPL';              Cat = 'Strong copyleft' }
    )

    foreach ($rule in $map) {
        if ($c -match $rule.Match) { return @{ Norm = $rule.Norm; Cat = $rule.Cat } }
    }

    if ($s -match '^(?i)licenseref') { return @{ Norm = $s; Cat = 'Custom (LicenseRef)' } }
    if ($s -match '^https?://')      { return @{ Norm = $s; Cat = 'Custom (URL)' } }
    return @{ Norm = $s; Cat = 'Custom - review manually' }
}

function New-LicenseRow {
    param([string]$File, [bool]$Nested, [string]$ContainerJar, [string]$Loader)
    return [PSCustomObject]@{
        File                    = $File
        Nested                  = $Nested
        ContainerJar            = $ContainerJar
        Loader                  = $Loader
        ModIds                  = $null
        DisplayName             = $null
        Version                 = $null
        Authors                 = $null
        Credits                 = $null
        LicenseDeclared         = $null
        LicenseNormalized       = $null
        LicenseCategory         = $null
        Homepage                = $null
        IssueTracker            = $null
        BundledLicenseFiles     = $null
        Sha1                    = $null
        PackVersion             = $PackVersion
        ModrinthProjectId       = $null
        ModrinthSlug            = $null
        ModrinthTitle           = $null
        ModrinthLicenseId       = $null
        ModrinthLicenseName     = $null
        ModrinthLicenseUrl      = $null
        ModrinthLicenseCategory = $null
        ModrinthUrl             = $null
        LicenseAgreement        = $null
    }
}

function Read-ModMetadata {
    param($Archive, [string]$SourceLabel, [string]$ContainerFile, [bool]$IsNested)

    $toml = Get-ZipEntryText -Archive $Archive -EntryName 'META-INF/neoforge.mods.toml'
    $loader = 'NeoForge'
    if ($null -eq $toml) {
        $toml = Get-ZipEntryText -Archive $Archive -EntryName 'META-INF/mods.toml'
        if ($null -ne $toml) { $loader = 'Forge (legacy toml)' }
    }

    $row = New-LicenseRow -File $SourceLabel -Nested $IsNested `
                          -ContainerJar $ContainerFile -Loader $loader

    if ($null -ne $toml) {
        $row.LicenseDeclared = Get-TomlString $toml 'license'
        $row.IssueTracker    = Get-TomlString $toml 'issueTrackerURL'
        $row.ModIds          = (Get-TomlStringAll $toml 'modId')       -join ', '
        $row.DisplayName     = (Get-TomlStringAll $toml 'displayName') -join ' | '
        $row.Version         = (Get-TomlStringAll $toml 'version')     -join ' | '
        $row.Authors         = (Get-TomlStringAll $toml 'authors')     -join ' | '
        $row.Credits         = (Get-TomlStringAll $toml 'credits')     -join ' | '
        $row.Homepage        = (Get-TomlStringAll $toml 'displayURL')  -join ' | '
    }
    else {
        $fmj = Get-ZipEntryText -Archive $Archive -EntryName 'fabric.mod.json'
        if ($null -ne $fmj) {
            $row.Loader = 'Fabric'
            try {
                $j = $fmj | ConvertFrom-Json
                $row.LicenseDeclared = ($j.license -join ', ')
                $row.ModIds          = $j.id
                $row.DisplayName     = $j.name
                $row.Version         = $j.version
                if ($j.authors) {
                    $row.Authors = (($j.authors | ForEach-Object {
                        if ($_ -is [string]) { $_ } else { $_.name }
                    }) -join ', ')
                }
                if ($j.contact) {
                    $row.Homepage     = $j.contact.homepage
                    $row.IssueTracker = $j.contact.issues
                }
            } catch { Write-Verbose "fabric.mod.json parse failed for $SourceLabel" }
        }
        else { $row.Loader = 'Unknown / not a mod' }
    }

    $licFiles = @()
    foreach ($e in $Archive.Entries) {
        if ($e.FullName -match '(?i)^(META-INF/)?(LICENSE|LICENCE|COPYING|NOTICE)([-_.][A-Za-z0-9]+)?(\.(txt|md|rst))?$') {
            $licFiles += $e.FullName
            if ($DumpLicenseFiles) {
                $safe = ($SourceLabel -replace '[\\/:*?"<>|]', '_')
                $dest = Join-Path (Join-Path $LicenseTextDir $safe) (($e.FullName -replace '[\\/]', '_'))
                Write-PackTextFile -Path $dest -Content (Get-ZipEntryText -Archive $Archive -EntryName $e.FullName)
            }
        }
    }
    $row.BundledLicenseFiles = ($licFiles -join '; ')

    $norm = Get-LicenseCategory $row.LicenseDeclared
    $row.LicenseNormalized = $norm.Norm
    $row.LicenseCategory   = $norm.Cat

    return $row
}

# ===========================================================================
# Pass 1: scan jars
# ===========================================================================

$jars = @(Get-ChildItem -LiteralPath $ModsFolder -Filter *.jar -File | Sort-Object Name)
Write-Host "`nFound $($jars.Count) jar(s)." -ForegroundColor Cyan

$results = New-Object System.Collections.Generic.List[object]
$i = 0

foreach ($jar in $jars) {
    $i++
    Write-Progress -Activity 'Reading mod metadata' -Status $jar.Name `
                   -PercentComplete (($i / [Math]::Max($jars.Count,1)) * 100)

    $zip = $null
    try { $zip = [System.IO.Compression.ZipFile]::OpenRead($jar.FullName) }
    catch {
        $bad = New-LicenseRow -File $jar.Name -Nested $false -ContainerJar '' `
                              -Loader 'ERROR: unreadable archive'
        $bad.LicenseNormalized = 'UNREADABLE'
        $bad.LicenseCategory   = 'Unknown'
        $results.Add($bad)
        continue
    }

    try {
        $row = Read-ModMetadata -Archive $zip -SourceLabel $jar.Name -ContainerFile '' -IsNested $false
        if (-not $NoHash) {
            # -LiteralPath, because plenty of mod jars ship [bracketed] filenames
            $row.Sha1 = (Get-FileHash -LiteralPath $jar.FullName -Algorithm SHA1).Hash.ToLowerInvariant()
        }
        $results.Add($row)

        if ($IncludeNested) {
            $nested = $zip.Entries | Where-Object { $_.FullName -match '(?i)^META-INF/jarjar/.+\.jar$' }
            foreach ($ne in $nested) {
                $ms = New-Object System.IO.MemoryStream
                $ns = $ne.Open()
                try { $ns.CopyTo($ms) } finally { $ns.Dispose() }
                $ms.Position = 0
                $nzip = $null
                try {
                    $nzip = New-Object System.IO.Compression.ZipArchive($ms, [System.IO.Compression.ZipArchiveMode]::Read)
                    $results.Add((Read-ModMetadata -Archive $nzip `
                                    -SourceLabel ([System.IO.Path]::GetFileName($ne.FullName)) `
                                    -ContainerFile $jar.Name -IsNested $true))
                }
                catch { Write-Verbose "Nested read failed: $($ne.FullName) in $($jar.Name)" }
                finally { if ($nzip) { $nzip.Dispose() }; $ms.Dispose() }
            }
        }
    }
    finally { $zip.Dispose() }
}
Write-Progress -Activity 'Reading mod metadata' -Completed

# ===========================================================================
# Pass 2: Modrinth cross-check (optional)
# ===========================================================================

if ($VerifyModrinth) {

    # PS 5.1 on older hosts still negotiates TLS 1.0 by default
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    # .NET parses User-Agent as product/version tokens plus (comments). A second
    # slash in the product token is rejected client-side, before any request is
    # made - so validate here rather than failing five batches deep.
    Add-Type -AssemblyName System.Net.Http
    try {
        $probe = New-Object System.Net.Http.HttpRequestMessage
        $probe.Headers.Add('User-Agent', $UserAgent)
        $probe.Dispose()
    }
    catch {
        throw "Invalid -UserAgent '$UserAgent'. Use one slash in the product token, e.g. 'MyPack-audit/1.0 (+https://example.com)'."
    }

    $headers = @{ 'User-Agent' = $UserAgent }
    if ($ModrinthToken) { $headers['Authorization'] = $ModrinthToken }

    function Invoke-ModrinthRequest {
        param([string]$Uri, [string]$Method = 'Get', $Body)
        $attempt = 0
        while ($attempt -lt 3) {
            $attempt++
            try {
                if ($Method -eq 'Post') {
                    return Invoke-RestMethod -Uri $Uri -Method Post -Headers $headers `
                            -ContentType 'application/json' -Body $Body -ErrorAction Stop
                }
                return Invoke-RestMethod -Uri $Uri -Method Get -Headers $headers -ErrorAction Stop
            }
            catch {
                $status = $null
                if ($_.Exception.Response) { try { $status = [int]$_.Exception.Response.StatusCode } catch {} }
                # ErrorDetails.Message is routinely null on 5.1, so lead with the exception text
                if ($status -eq 429) {
                    Write-Warning "429 rate limited; backing off $($attempt * 5)s"
                    Start-Sleep -Seconds ($attempt * 5); continue
                }
                # No status and no response means the request never left the
                # machine - a malformed header or bad URI. Retrying is pointless.
                if (-not $status -and -not $_.Exception.Response) {
                    throw "Modrinth request could not be sent: $($_.Exception.Message)"
                }
                Write-Warning "Modrinth request failed (attempt $attempt) [$status]: $($_.Exception.Message)"
                if ($attempt -ge 3) { return $null }
                Start-Sleep -Seconds 2
            }
        }
        return $null
    }

    $hashes = @($results | Where-Object { $_.Sha1 } | ForEach-Object { $_.Sha1 } | Select-Object -Unique)
    Write-Host "`nResolving $($hashes.Count) unique SHA1(s) against Modrinth..." -ForegroundColor Cyan

    $hashToProject = @{}
    $failedBatches = 0

    for ($i = 0; $i -lt $hashes.Count; $i += $BatchSize) {
        $chunk = $hashes[$i..([Math]::Min($i + $BatchSize - 1, $hashes.Count - 1))]
        $body  = @{ hashes = $chunk; algorithm = 'sha1' } | ConvertTo-Json -Compress

        $resp = Invoke-ModrinthRequest -Uri "$ApiBase/version_files" -Method Post -Body $body
        if ($null -eq $resp) { $failedBatches++; continue }

        # The response is an object keyed by hash. PS 5.1 has no
        # ConvertFrom-Json -AsHashtable, so walk the PSCustomObject properties.
        foreach ($prop in $resp.PSObject.Properties) {
            $hashToProject[$prop.Name.ToLowerInvariant()] = $prop.Value.project_id
        }
        $done = [Math]::Min($i + $BatchSize, $hashes.Count)
        Write-Progress -Activity 'Modrinth: resolving hashes' `
                       -Status "$done / $($hashes.Count)" `
                       -PercentComplete (($done / $hashes.Count) * 100)
        Start-Sleep -Milliseconds $ThrottleMs
    }
    Write-Progress -Activity 'Modrinth: resolving hashes' -Completed
    Write-Host "  Resolved $($hashToProject.Count) of $($hashes.Count) file(s)." -ForegroundColor Green

    $projectIds = @($hashToProject.Values | Where-Object { $_ } | Select-Object -Unique)
    $projects   = @{}
    Write-Host "Fetching $($projectIds.Count) project record(s)..." -ForegroundColor Cyan

    for ($i = 0; $i -lt $projectIds.Count; $i += $BatchSize) {
        $chunk   = $projectIds[$i..([Math]::Min($i + $BatchSize - 1, $projectIds.Count - 1))]
        $idsJson = ConvertTo-Json -InputObject @($chunk) -Compress
        $uri     = "$ApiBase/projects?ids=" + [System.Uri]::EscapeDataString($idsJson)

        $resp = Invoke-ModrinthRequest -Uri $uri
        if ($null -eq $resp) { $failedBatches++; continue }
        foreach ($p in @($resp)) { $projects[$p.id] = $p }

        $done = [Math]::Min($i + $BatchSize, $projectIds.Count)
        Write-Progress -Activity 'Modrinth: fetching projects' `
                       -Status "$done / $($projectIds.Count)" `
                       -PercentComplete (($done / $projectIds.Count) * 100)
        Start-Sleep -Milliseconds $ThrottleMs
    }
    Write-Progress -Activity 'Modrinth: fetching projects' -Completed
    Write-Host "  Fetched $($projects.Count) project(s)." -ForegroundColor Green

    if ($failedBatches -gt 0) {
        Write-Warning "$failedBatches batch(es) failed outright - verification is incomplete."
    }

    foreach ($row in $results) {
        # Reset per row. Leaving this outside the loop lets a previous row's
        # normalized value leak into the comparison below.
        $mNorm = $null

        if ($row.Sha1 -and $hashToProject.ContainsKey($row.Sha1)) {
            # NOT $pid - that is a read-only automatic variable (process ID)
            $projId = $hashToProject[$row.Sha1]
            $row.ModrinthProjectId = $projId
            if ($projects.ContainsKey($projId)) {
                $p = $projects[$projId]
                $row.ModrinthSlug        = $p.slug
                $row.ModrinthTitle       = $p.title
                $row.ModrinthLicenseId   = $p.license.id
                $row.ModrinthLicenseName = $p.license.name
                $row.ModrinthLicenseUrl  = $p.license.url
                $ptype = if ($p.project_type) { $p.project_type } else { 'mod' }
                $row.ModrinthUrl = "https://modrinth.com/$ptype/$($p.slug)"

                $n = Get-LicenseCategory $p.license.id
                $row.ModrinthLicenseCategory = $n.Cat
                $mNorm = $n.Norm
            }
        }

        if (-not $row.ModrinthProjectId) { $row.LicenseAgreement = 'NotOnModrinth' }
        elseif ([string]::IsNullOrWhiteSpace($row.LicenseDeclared)) { $row.LicenseAgreement = 'JarUndeclared' }
        elseif ($row.ModrinthLicenseCategory -in @('Custom (LicenseRef)','Custom - review manually')) {
            $row.LicenseAgreement = 'ModrinthCustom'
        }
        elseif ($row.LicenseCategory -eq $row.ModrinthLicenseCategory) {
            $row.LicenseAgreement = if ($row.LicenseNormalized -eq $mNorm) { 'Match' } else { 'NEAR-MATCH' }
        }
        else { $row.LicenseAgreement = 'MISMATCH' }
    }
}

# ===========================================================================
# Output
# ===========================================================================

$columns = @(
    'File','Nested','ContainerJar','Loader','ModIds','DisplayName','Version',
    'Authors','Credits','LicenseDeclared','LicenseNormalized','LicenseCategory',
    'Homepage','IssueTracker','BundledLicenseFiles','Sha1','PackVersion'
)
if ($VerifyModrinth) {
    $columns += @(
        'ModrinthProjectId','ModrinthSlug','ModrinthTitle','ModrinthLicenseId',
        'ModrinthLicenseName','ModrinthLicenseUrl','ModrinthLicenseCategory',
        'ModrinthUrl','LicenseAgreement'
    )
}

Write-Host "`nWriting output..." -ForegroundColor Cyan
$null = Write-PackCsvFile -Rows $results.ToArray() -Columns $columns -Path $OutCsv -Label 'mod-licenses'

# ---------------------------------------------------------------------------
# Report
# ---------------------------------------------------------------------------

Write-Host "`n=== License category breakdown ===" -ForegroundColor Cyan
$results | Group-Object LicenseCategory | Sort-Object Count -Descending |
    Format-Table @{N='Count';E={$_.Count}}, @{N='Category';E={$_.Name}} -AutoSize

if ($VerifyModrinth) {
    Write-Host "=== Modrinth agreement ===" -ForegroundColor Cyan
    $results | Group-Object LicenseAgreement | Sort-Object Count -Descending |
        Format-Table @{N='Count';E={$_.Count}}, @{N='Verdict';E={$_.Name}} -AutoSize

    $mismatches = $results | Where-Object { $_.LicenseAgreement -eq 'MISMATCH' }
    if ($mismatches) {
        Write-Host "=== MISMATCHES - resolve before publishing ===" -ForegroundColor Red
        $mismatches | Select-Object File,
            @{N='Jar';E={$_.LicenseDeclared}},
            @{N='Modrinth';E={$_.ModrinthLicenseId}},
            ModrinthUrl | Format-Table -AutoSize -Wrap
    }

    $custom = $results | Where-Object { $_.LicenseAgreement -eq 'ModrinthCustom' }
    if ($custom) {
        Write-Host "=== Custom licenses - read the linked terms ===" -ForegroundColor Yellow
        $custom | Select-Object File, ModrinthLicenseName, ModrinthLicenseUrl, ModrinthUrl |
            Format-Table -AutoSize -Wrap
    }
}

Write-Host "=== Needs manual review ===" -ForegroundColor Yellow
$review = $results | Where-Object {
    $_.LicenseCategory -in @('Unknown','Custom - review manually','Custom (URL)','ARR - check terms')
}
if ($review) {
    $review | Select-Object File, LicenseDeclared, LicenseCategory |
        Sort-Object LicenseCategory, File | Format-Table -AutoSize
} else {
    Write-Host "  (none)" -ForegroundColor DarkGray
}

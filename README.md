# Forge Everything

A NeoForge 1.21.1 modpack. Not a kitchen sink — the entire kitchen, the sink, the cabinets, the fridge, and whatever's growing in the back of it.

~486 client / ~442 server mods, plus companion mods built in-house: **Everything Ores**, **Everything Food**, and **Everything Bugs**.

---

## Just want to play?

Go to [Releases](../../releases/latest), download the client zip, and import it into Prism Launcher. You do not need this repo, packwiz, or anything below.

**This repo contains no mods.** It contains ~490 small TOML files describing *where* each mod lives. Cloning it does not give you a playable pack.

Everything below is for people editing the pack.

---

## Contributor setup

### 1. Install packwiz

Grab a binary from [packwiz releases](https://github.com/packwiz/packwiz/releases), or build it:

```bash
go install github.com/packwiz/packwiz@latest
```

Put it on your `PATH` and verify:

```bash
packwiz --version
```

### 2. Clone

```bash
git clone https://github.com/Rexilyent/forge-everything.git
cd forge-everything/packwiz
```

Every packwiz command runs from the `packwiz/` directory — the one containing `pack.toml`.

### 3. Set up a test instance

Point a Prism instance at your **local clone** so you can see changes without pushing. Same setup as the released instance, but the pre-launch command uses a local path:

```
"$INST_JAVA" -jar "$INST_MC_DIR/packwiz-installer-bootstrap.jar" "C:/path/to/forge-everything/packwiz/pack.toml"
```

Keep a second instance pointed at the published URL, so you can reproduce what testers actually see.

---

## The one rule

> **Run `packwiz refresh` before every commit.**

`index.toml` stores a hash of every file in the pack. Commit without refreshing and the index describes files that no longer match it. **The failure never appears on your machine** — it appears on everyone else's, as a hash mismatch at launch. Refresh takes a second. Do it every time.

---

## Adding mods

### One at a time

```bash
cd packwiz

packwiz mr add <modrinth-slug>       # Modrinth
packwiz cf add <curseforge-slug>     # CurseForge
packwiz refresh
```

Then commit and push.

### CurseForge API is currently blocked

`packwiz cf add` hits the CurseForge API, which returns **HTTP 403** from the primary dev machine. Believed to be IP-level; a new API key does not fix it.

Do **not** retry repeatedly — repeated rejected requests are what extend these blocks. Use the worksheet workflow below instead.

### Removing and updating

```bash
packwiz remove <slug>
packwiz update <slug>          # one mod
packwiz update --all           # everything — review the diff carefully
packwiz refresh
```

At ~490 mods, one bad version bump can leave the whole team unable to launch. Read the `git diff` before pushing an `--all`.

---

## Bulk import

For importing a whole instance's worth of mods, or reconciling the pack against a working instance. Scripts live in the repo root and are PowerShell 5.1 compatible.

### The pipeline

```powershell
# 1. Hash every jar in an instance
.\Get-ModFolderInventory.ps1 -ModsFolder "<instance>\mods" -OutputCsv .\mod-folder-inventory.csv

# 2. Resolve those hashes against Modrinth and CurseForge, write .pw.toml entries
.\Resolve-InstanceByHash.ps1 `
    -InventoryCsv .\mod-folder-inventory.csv `
    -LinksFile .\links_to_mods.txt `
    -Apply -PackDir .\packwiz

# 3. For anything CurseForge could not resolve (see API note above)
.\Build-CurseforgeEntries.ps1 `
    -ReportCsv .\hash-resolution-report.csv `
    -LinksFile .\links_to_mods.txt `
    -InstanceModsFolder "<instance>\mods"
#    ... fill in ProjectId + FileId in curseforge-worksheet.csv, then:
.\Build-CurseforgeEntries.ps1 -Apply -WorksheetCsv .\curseforge-worksheet.csv -PackDir .\packwiz

# 4. Set client/server sides from the working server
.\Set-ModSides.ps1 -ServerModsFolder "<server>\mods" -PackDir .\packwiz -Apply

# 5. Always
cd packwiz; packwiz refresh
```

Steps 3 and 4 default to a dry run — nothing is written without `-Apply`.

### Why hashes and not URLs

The installed jar's SHA1 is ground truth. Resolving *that* against platform APIs cannot produce a wrong-version or wrong-filetype entry, which URL parsing routinely does. If a hash resolves, the entry is correct by construction.

### The scripts

| Script | Purpose |
|---|---|
| `Get-ModFolderInventory.ps1` | Hashes a mods folder into a CSV |
| `Resolve-InstanceByHash.ps1` | Resolves SHA1s against Modrinth + CurseForge, writes `.pw.toml`. Also `-SelfTest`, `-TestCfKey`, `-CfStatus` |
| `Build-CurseforgeEntries.ps1` | Builds CurseForge entries with **no API access**, from a hand-completed worksheet |
| `Set-ModSides.ps1` | Sets `side` from the server's mods folder |

### The CurseForge governor

`Resolve-InstanceByHash.ps1` throttles itself: a request ledger persisted across runs, a disk cache so re-runs cost zero requests, and a circuit breaker that escalates (1h → 2h → 4h … 24h) each time CurseForge rejects a request.

```powershell
.\Resolve-InstanceByHash.ps1 -CfStatus    # budget, cache size, cooldown, strikes
.\Resolve-InstanceByHash.ps1 -TestCfKey   # one live probe
```

If the breaker trips, **let it run**. Clearing the cooldown to retry is what deepens these blocks.

### Secrets

API keys go in `secrets.local.env` at the repo root, gitignored:

```
CF_API_KEY=$2a$10$...
MODRINTH_TOKEN=...
```

Unquoted, one per line. PowerShell interpolates `$` inside double quotes and will silently mangle a bcrypt-format key — if you set one as an environment variable, use single quotes.

---

## Sides

`side` decides who receives a mod. The server's mods folder is the source of truth:

- jar is on the server → `side = "both"`
- jar is not on the server → `side = "client"`

The client installer passes no `-s` flag and gets `both` + `client`. The server passes `-s server` and gets `both` + `server`.

`Set-ModSides.ps1` derives this automatically. It also reports jars running on the server that have no pack entry — those are hand-maintained today and would vanish the first time that server syncs from packwiz.

---

## Loose jars

Five jars ship directly from this repo rather than as metadata:

| Jar | Why |
|---|---|
| `everythingores.jar` | Ours. Not published anywhere. |
| `everythingbugs.jar` | Ours. Not published anywhere. |
| `everythingfood.jar` | Ours. Not published anywhere. |
| `ars_elemental-*.jar` | LGPL; author disabled CurseForge third-party distribution |
| `chisels-and-bits-*.jar` | LGPL; same |

Loose jars have **no `side` field** and always install on both client and server.

**When updating one:**

1. **Delete the old jar first.** Two versions of the same mod in `mods/` means packwiz ships both, and NeoForge hard-fails on the duplicate mod ID.
2. Copy in the new jar.
3. `packwiz refresh` — the index stores the jar's hash, and a stale hash breaks every client.
4. Commit and push.

`.packwizignore` allows only these four through; any other stray jar in `mods/` is skipped rather than published.

See `THIRD-PARTY.md` for LGPL attribution.

---

## Branches

The `pack.toml` URL contains the branch name, so branches are release channels:

| Branch | Who points at it |
|---|---|
| `main` | Testers. Blessed builds only. |
| `dev` | Us. May be broken. |

Work on `dev`, merge to `main` when a build is worth broad testing, and bump `version` in `pack.toml` on each merge.

---

## Repo layout

```
packwiz/
├── pack.toml            # entry point: versions, index hash
├── index.toml           # hash of every file below — generated, never hand-edit
├── mods/                # ~490 .pw.toml + 4 loose jars
├── config/              # mod configs — these matter, see below
├── resourcepacks/
├── shaderpacks/
└── .packwizignore

*.ps1                    # tooling (see Bulk import)
curseforge-worksheet.csv # CurseForge project/file IDs, hand-maintained
```

### Configs are not optional

Several encode fixes that took real effort to find. Shipping without them means re-living the bugs:

- **Ballistix** — `should_cache_explosions = false`. Without it, ~1.25 GB retained at startup.
- **Quark** — `AutomaticRecipeUnlockModule` disabled. Without it, a 35–38 s stall on join.
- **InControl** — 315 spawn rules. Without them, 40–60% more mob AI overhead.
- **forgeeverything_datapack** (Paxi) — ore worldgen suppression. Without it, every duplicate ore generates again and Everything Ores' unification is invisible.

Adding a mod that needs config to behave? Commit the config in the same change.

---

## Troubleshooting

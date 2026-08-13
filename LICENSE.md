# Licensing & Attribution

**Forge Everything** — a NeoForge 1.21.1 kitchen-sink modpack.

| | |
|---|---|
| Pack version | `v0.0.1-Alpha` |
| Minecraft / loader | 1.21.1 · NeoForge |
| Mods bundled | 496 |
| Audit generated | 2026-08-13 |

Look. We know. It's a license file with 496 rows in it. Nobody asked for this.

But here's the thing — every mod in this pack is somebody's actual work, usually unpaid, usually done at 2am because they thought a block should exist. The bare minimum we can do is know exactly whose work is in here and under what terms. So we automated it, and then we automated it *harder*, and now there's a script that cracks open all 496 jars and cross-checks three separate sources. Is that overboard? Absolutely. Do we regret it? Not even slightly.

Anyway. This document is produced by `Get-ModLicenses.ps1`, which reads three independent sources for every mod in the pack:

1. **The LICENSE file bundled inside the jar** — the license text that actually travels with the code. Most authoritative where it exists.
2. **The Modrinth project listing** — a curated SPDX identifier, matched to each jar by SHA-1.
3. **The `license` field in `META-INF/neoforge.mods.toml`** — free text, and very frequently still the NeoForge MDK's `All Rights Reserved` placeholder that nobody remembered to change. No shade. We've all shipped boilerplate.

Where these disagree the discrepancy is recorded rather than silently resolved. 96 of the 496 jars ship a license file, and 17 of those contradict their own toml.

### Check our work

We're not asking you to take this table's word for anything. The raw audit output ships in the repo alongside this file:

| Path | What it is |
|---|---|
| `reports/mod-licenses.csv` | Every field pulled from every jar — exact license strings before normalization, mod IDs, authors, homepages, issue trackers, file SHA-1s, and the matched Modrinth project and license for each. One row per mod. |
| `reports/license-texts/` | The complete, unedited LICENSE, COPYING and NOTICE files extracted from all 96 jars that ship one, filed under the jar they came from. |

Between them you can reproduce every claim in this document, or catch us getting one wrong. The CSV keeps the original license strings *before* we bucket them into families, so if you disagree with how something was categorised you can see exactly what the author actually wrote. The SHA-1 column means you can verify that the jar we audited is the jar you downloaded when installing this modpack.

Regenerate both at any time with:

```powershell
.\Get-ModLicenses.ps1 -VerifyModrinth -DumpLicenseFiles
```

Keeping the extracted license texts in the repo is deliberate for a second reason: several licenses here — Apache-2.0, the LGPL family, the tr7zw Protective License, the Supplementaries Team License — require that copyright and permission notices be reproduced wherever the software goes. `reports/license-texts/` is that reproduction, carried verbatim and unmodified along with the same file being shipped within each jar file.

---

## What Forge Everything owns

Short version: the glue is ours, the mods are not.

Everything in this section is original work by the Forge Everything team. It's the only part of this project we're actually in a position to license to you, so it's the only part we'll make claims about.

**First-party mods** — written from scratch by us:

- **Everything Ores** (`everythingores`) — ore unification. Owns the duplicate ore and gem entries for the pack so participating mods resolve to a single source through NeoForge tags instead of each adding their own worldgen.
- **Everything Bugs** (`everythingbugs`) — cross-mod compatibility and stability patches, applied as mixins.
- **Everything Food** (`everythingfood`) — food and nutrition unification companion.

**Pack content** — also ours:

- `forgeeverything_datapack` — tag corrections, worldgen and ore suppression overrides, custom structures and loot tables.
- All FTB Quests chapters, quest text, reward tables and progression design.
- All KubeJS scripts, recipe and tag overrides.
- Pack configuration, mod selection and balance tuning.
- The *Forge Everything* name, branding, logo and associated artwork.
- The PowerShell tooling suite used to build and audit the pack.

> **License for our work:** _[TEAM: choose and state a license here — e.g. MIT for the first-party mods and scripts, CC BY-NC-SA 4.0 for the quest content and artwork. Until this line is filled in, no permission is granted to reuse our work. (This does not mean you can take the entire modpack, parts of the pack, the name, logo, textures, or everything branded mods and reupload for redistribution.)]_

### What we do not own

Everything else. All of it. Every mod listed below belongs to whoever wrote it — we didn't make them, we don't own them, and nothing in this document hands you (or us) any rights to them. We just picked them and made them play nice together.

Forge Everything is distributed as a **metadata manifest**, not as a bundle of mod jars. When you install the pack, your launcher downloads each mod directly from the author's own distribution platform. We do not rehost, repackage or modify anyone's mod files. This matters legally as well as practically: several licenses in this pack grant modpack use *specifically on the condition that the mod is not directly bundled*, and manifest distribution is what satisfies them.

Where we needed to change how a mod behaves — recipe changes, tag reassignments, disabled worldgen — that is done externally through datapacks, KubeJS and configuration. The jars themselves ship unmodified.

**Exceptions.** Two mods have author-disabled third-party distribution on CurseForge and so cannot be fetched by manifest. Both are LGPL, which permits redistribution, and both are therefore carried directly in the pack:

- **Ars Elemental**
- **Chisels & Bits**

_[TEAM: confirm this list is still current before publishing, and decide whether a `THIRD-PARTY.md` carrying the full LGPL notice text should be linked from here.]_

---

## Obligations this pack has taken on

Some authors said yes *with strings attached*. These are the strings. This is the one section of this document that is not vibes — every line here is a condition we agreed to by shipping their mod, and "we didn't read it" has never worked as a defence.

| Obligation | Owed to | Status |
|---|---|---|
| **Credit and link** each mod somewhere visible | Stardust Labs — Nullscape, Structory, Structory: Towers | _[TEAM: confirm a quest-book credits page or pack description satisfies this]_ |
| **Do not bundle jars directly** — manifest distribution only | Supplementaries Team, Stardust Labs, tr7zw | Satisfied by packwiz manifest distribution |
| **Do not monetise the pack** — no commercial advantage or compensation | tr7zw — EntityCulling, NotEnoughAnimations, 3d-Skin-Layers, WaveyCapes | _[TEAM: confirm no monetisation, including ad-supported hosting]_ |
| **Reproduce copyright and permission notices** | tr7zw, Supplementaries Team, and every Apache-2.0 and LGPL mod | Partly met — full notices carried verbatim in `reports/license-texts/`. _[TEAM: confirm whether a consolidated `THIRD-PARTY.md` is still wanted for the two self-hosted jars]_ |
| **Do not override Stardust Labs' own structures** via datapack | Stardust Labs | _[TEAM: audit `forgeeverything_datapack` — adding structures and altering loot tables is explicitly allowed, overriding their structures is not]_ |

---

## For mod authors

Hi. Thanks for making the thing.

If you wrote one of the mods below and you want it out of Forge Everything, just say so — open an issue on our repo or message the team. We'll pull it, no argument, no negotiation, no guilt-tripping you about it. Your work, your call.

And if we've got your license wrong below — very possible, especially where your jar's `neoforge.mods.toml` says one thing and your published license says another — please tell us. We'd rather be corrected than keep guessing confidently in public.

---

## Summary

| License family | Mods |
|---|---:|
| Permissive | 195 |
| All Rights Reserved | 112 |
| Weak copyleft | 111 |
| Custom | 41 |
| Strong copyleft | 18 |
| CC (non-commercial) | 9 |
| CC (no derivatives) | 8 |
| CC (share-alike) | 1 |
| CC (attribution) | 1 |
| **Total** | **496** |

Where a bundled LICENSE file contradicted the toml, the family above follows the **bundled file**.

### Source agreement

| Result | Mods | Meaning |
|---|---:|---|
| Match | 324 | Jar and Modrinth agree. |
| Unlisted | 74 | Not resolvable on Modrinth (CurseForge-only or unpublished). |
| Conflict | 57 | Jar and Modrinth disagree — see below. |
| Near match | 38 | Same license, different spelling. |
| Jar undeclared | 3 | No license in the jar; Modrinth's value used. |

### Jars that contradict themselves

These jars are arguing with themselves. The LICENSE file inside says one thing, the `license` field in the *same jar's* toml says another. Usually the toml is just stale boilerplate and the bundled file is the truth — but a few go the other way and land on something **more** restrictive, so we don't get to assume. Each one gets read properly.

| Mod | toml says | Modrinth says | Bundled file says |
|---|---|---|---|
| 3d-Skin-Layers | tr7zw Protective License | LicenseRef-tr7zw-Protective-License | **MIT** |
| AddonsLib | All Rights Reserved | All Rights Reserved | **CC0-1.0** |
| Amendments | Supplementaries Team License v.1.5 | LicenseRef-Supplementaries-Team-License-1.1 | **All Rights Reserved** |
| Ars Nouveau | GPL-3.0 | GPL-3.0 | **Apache-2.0** |
| Better Compatibility Checker | All Rights Reserved | All Rights Reserved | **Custom** |
| EntityCulling | tr7zw Protective License | LicenseRef-tr7zw-Protective-License | **MIT** |
| Euphoria Patcher | MPL-2.0 | MPL-2.0 | **Apache-2.0+BSD** |
| Icarus | See linked terms | LicenseRef-Custom | **MIT** |
| IntegratedScripting | MIT | MIT | **Custom** |
| MonoLib | Unlicense | Unlicense | **Custom** |
| No Chat Reports | WTFPL | WTFPL | **Custom** |
| NotEnoughAnimations | tr7zw Protective License | LicenseRef-tr7zw-Protective-License | **MIT** |
| Sparkweave Engine | See linked terms | All Rights Reserved | **All Rights Reserved** |
| Supplementaries | Supplementaries Team License v.1.5 | LicenseRef-Supplementaries-Team-License | **All Rights Reserved** |
| The Bumblezone | MIT | All Rights Reserved | **All Rights Reserved+LGPL-3.0** |
| WaveyCapes | tr7zw Protective License | LicenseRef-tr7zw-Protective-License | **MIT** |
| Zero CORE 2 | All Rights Reserved | All Rights Reserved | **MIT** |

### Jar vs. Modrinth conflicts

Jar says one thing, Modrinth says another. Nine times out of ten it's a `mods.toml` that never got updated after a relicense. Until someone confirms which is current, **we assume the stricter one.** Being wrong in that direction costs us a mod; being wrong the other way costs somebody else their rights.

| Mod | In jar | On Modrinth | Links |
|---|---|---|---|
| Accelerated Decay | GPL-3.0 | LGPL-3.0 | [Modrinth](https://modrinth.com/mod/accelerated-decay) |
| Advanced Netherite | GPL-3.0 | LicenseRef-Custom | [Modrinth](https://modrinth.com/mod/advanced-netherite) · [Terms](https://github.com/Autovw/AdvancedNetherite/blob/1.18.X/LICENSE) |
| Advanced Peripherals | All Rights Reserved | Apache-2.0 | [Modrinth](https://modrinth.com/mod/advancedperipherals) |
| Applied Energistics 2 | Undeclared | LicenseRef-Multiple | [Modrinth](https://modrinth.com/mod/ae2) · [Terms](https://github.com/AppliedEnergistics/Applied-Energistics-2#license) |
| Applied Mekanistics | Undeclared | LGPL-3.0 | [Modrinth](https://modrinth.com/mod/applied-mekanistics) |
| Ars Creo | LGPL-3.0 | GPL-3.0 | [Modrinth](https://modrinth.com/mod/ars-creo) |
| Assembly Line | All Rights Reserved | LicenseRef-AURILISDEV-LICENSE-1.0… | [Modrinth](https://modrinth.com/mod/assembly-lines) · [Terms](https://github.com/aurilisdev/Assembly-Line/blob/1.19.2/LICENSE.txt) |
| Ballistix | All Rights Reserved | LicenseRef-AURILISDEV-LICENSE-1.02 | [Modrinth](https://modrinth.com/mod/ballistix) · [Terms](https://github.com/aurilisdev/Electrodynamics/blob/1.20/LICENSE.txt) |
| Blastcraft | All Rights Reserved | LicenseRef-AURILISDEV-LICENSE-1.0… | [Modrinth](https://modrinth.com/mod/blastcraft) · [Terms](https://github.com/aurilisdev/Electrodynamics/blob/1.20/LICENSE.txt) |
| Chipped | Terrarium License | All Rights Reserved | [Modrinth](https://modrinth.com/mod/chipped) |
| Colorwheel Patcher | ARR | All Rights Reserved | [Modrinth](https://modrinth.com/mod/colorwheel-patcher) |
| Crafting On A Stick | GPL-3.0 | All Rights Reserved | [Modrinth](https://modrinth.com/mod/crafting-on-a-stick) |
| Create | Undeclared | LicenseRef-Create-Mod-License | [Modrinth](https://modrinth.com/mod/create) · [Terms](https://github.com/Creators-of-Create/Create/blob/HEAD/LICENSE.md) |
| Create Big Cannons | MIT | LicenseRef-Create-Big-Cannons-Lic… | [Modrinth](https://modrinth.com/mod/create-big-cannons) · [Terms](https://github.com/Cannoneers-of-Create/CreateBigCannons/blob/0b3e23456f38bac359112d82d6aad1b5430c04d1/LICENSE.md) |
| Create Deco | All Rights Reserved | MIT | [Modrinth](https://modrinth.com/mod/create-deco) |
| Create Nuclear | All Rights Reserved | MIT | [Modrinth](https://modrinth.com/mod/createnuclear) |
| Create: Dreams n' Desires | MIT | LicenseRef-MIT-Code-AND-ARR-Art | [Modrinth](https://modrinth.com/mod/create-dreams-and-desires) |
| Create: Interiors | MIT | GPL-3.0 | [Modrinth](https://modrinth.com/mod/interiors) |
| Deep Aether | GPL-3.0 | LGPL-3.0 | [Modrinth](https://modrinth.com/mod/deep-aether) |
| Design n' Decor | MIT | LicenseRef-MIT-Code-AND-ARR-Art | [Modrinth](https://modrinth.com/mod/create-design-n-decor) |
| Dis-Enchanting Table | Unlicense | All Rights Reserved | [Modrinth](https://modrinth.com/mod/dis-enchanting-table) |
| EdivadLib | AGPL-3.0 | LGPL-3.0 | [Modrinth](https://modrinth.com/mod/edivadlib) |
| Enderman Overhaul | ARR | All Rights Reserved | [Modrinth](https://modrinth.com/mod/enderman-overhaul) |
| Explore Ruins Aether | Undeclared | All Rights Reserved | [Modrinth](https://modrinth.com/mod/explore-ruins-aether) |
| Explorify | ARR | All Rights Reserved | [Modrinth](https://modrinth.com/mod/explorify) |
| FlickerFix | All Rights Reserved | MIT | [Modrinth](https://modrinth.com/mod/flickerfix) |
| GuideME | Undeclared | LicenseRef-Multiple-OSS-Licenses | [Modrinth](https://modrinth.com/mod/guideme) · [Terms](https://github.com/AppliedEnergistics/GuideME/blob/main/LICENSE.MD) |
| Hellish Trials | ARR | All Rights Reserved | [Modrinth](https://modrinth.com/mod/hellish-trials) |
| Just Enough Effects Descriptions | GPL-3.0 | All Rights Reserved | [Modrinth](https://modrinth.com/mod/just-enough-effect-descriptions-jeed) |
| KubeJS Additions | All Rights Reserved | MIT | [Modrinth](https://modrinth.com/mod/kubejs-additions) |
| KubeJS Create | MIT | LGPL-3.0 | [Modrinth](https://modrinth.com/mod/kubejs-create) |
| L_Ender's Cataclysm 1.21.1 | LGPL-3.0 | CC BY-NC-ND | [Modrinth](https://modrinth.com/mod/l_enders-cataclysm) |
| legendary_monsters | Undeclared | All Rights Reserved | [Modrinth](https://modrinth.com/mod/legendary-monsters) |
| Lootr | See linked terms | MIT | [Modrinth](https://modrinth.com/mod/lootr) |
| MmmMmmMmmMmm | Supplementaries Team License v.1.5 | CC0-1.0 | [Modrinth](https://modrinth.com/mod/mmmmmmmmmmmm) |
| Modular Force Fields | All Rights Reserved | LicenseRef-AURILISDEV-LICENSE-1.0… | [Modrinth](https://modrinth.com/mod/modular-force-field-systems) · [Terms](https://github.com/aurilisdev/Electrodynamics/blob/1.20/LICENSE.txt) |
| Moog's Structure Lib | See linked terms | LGPL-3.0 | [Modrinth](https://modrinth.com/mod/moogs-structure-lib) |
| Moonlight Lib | Supplementaries Team License v.1.5 | LGPL | [Modrinth](https://modrinth.com/mod/moonlight) · [Terms](https://github.com/MehVahdJukaar/Moonlight/blob/1.20/license.md) |
| MSS - Moog's Soaring Structures | LGPL-3.0 | GPL-3.0 | [Modrinth](https://modrinth.com/mod/mss-moogs-soaring-structures) |
| MVS - Moog's Voyager Structures | LGPL-3.0 | MIT | [Modrinth](https://modrinth.com/mod/moogs-voyager-structures) |
| Oritech | CC0-1.0 | CC BY | [Modrinth](https://modrinth.com/mod/oritech) · [Terms](https://github.com/Rearth/Oritech?tab=CC0-1.0-1-ov-file) |
| PneumaticCraft: Repressurized | GPL-3.0 | LGPL-2.1 | [Modrinth](https://modrinth.com/mod/pneumaticcraft-repressurized) |
| ProbeJS | GPL-3.0 | LGPL-2.1 | [Modrinth](https://modrinth.com/mod/probejs) |
| Protect Your Moa | LGPL-3.0 | LicenseRef-Custom | [Modrinth](https://modrinth.com/mod/aether-protect-your-moa) · [Terms](https://github.com/The-Aether-Team/Protect-Your-Moa#scroll-license-information) |
| Quark | See linked terms | CC BY-NC-SA | [Modrinth](https://modrinth.com/mod/quark) |
| Regions Unexplored | All Rights Reserved | MIT | [Modrinth](https://modrinth.com/mod/regions-unexplored) |
| Sky Aesthetics | Undeclared | MIT | [Modrinth](https://modrinth.com/mod/sky-aesthetics) |
| Smarter Farmers | Supplementaries Team License v.1.4 | All Rights Reserved | [Modrinth](https://modrinth.com/mod/smarter-farmers-farmers-replant) |
| Sparkweave Engine | See linked terms | All Rights Reserved | [Modrinth](https://modrinth.com/mod/sparkweave) |
| The Aether | LGPL-3.0 | LicenseRef-Custom | [Modrinth](https://modrinth.com/mod/aether) · [Terms](https://github.com/The-Aether-Team/The-Aether#scroll-license-information) |
| The Bumblezone | MIT | All Rights Reserved | [Modrinth](https://modrinth.com/mod/the-bumblezone) |
| The Undergarden | MIT | All Rights Reserved | [Modrinth](https://modrinth.com/mod/the-undergarden) |
| Titanium | LGPL | MIT | [Modrinth](https://modrinth.com/mod/titanium) |
| Valhelsia Core | All Rights Reserved | LicenseRef-Custom | [Modrinth](https://modrinth.com/mod/valhelsia-core) |
| Variants&Ventures | CC BY-NC-ND | LicenseRef-CC-BY-NC-ND-4.0 | [Modrinth](https://modrinth.com/mod/variants-and-ventures) · [Terms](https://raw.githubusercontent.com/Faboslav/variants-and-ventures/master/LICENSE.txt) |
| Witchery | All Rights Reserved | LGPL-3.0 | [Modrinth](https://modrinth.com/mod/just-another-witchery-remake) |
| Zeta | See linked terms | CC BY-NC-SA | [Modrinth](https://modrinth.com/mod/zeta) · [Terms](https://github.com/VazkiiMods/Zeta/blob/main/LICENSE.md) |

---

## Permission tracking

Two columns in the master table are maintained **by hand** by the team:

- **Modpack use permitted** — does this mod's license or distribution policy allow inclusion in a public modpack? Record `Yes`, `No`, or `Ask`. A permissive code license does not always cover a mod's *assets*, and a platform's "allow third-party distribution" toggle is separate from the license entirely.
- **Explicit permission** — has the author personally granted us permission? Record where and when (e.g. `Discord 2026-03-04`, `Issue #12`), not just `Yes`. A dated pointer is what makes this defensible.

### Established from bundled license text (21 mods)

Actual permission, in writing, straight from the LICENSE files shipped inside the jars — not inferred from an SPDX tag, not vibes-based. Where a grant came with conditions, those conditions are real and are tracked in *Obligations* above.

**Yes — with attribution** — Nullscape, Structory, Structory: Towers

> Unmodified use in a publicly distributed modpack is permitted, including for-profit. Credit to Stardust Labs and a link to each mod are **required**. Overriding their datapack's own structures is prohibited; adding structures or altering structure generation is allowed, and loot table changes are allowed unconditionally.
>
> *Source: bundled LICENSE — Stardust Labs License, rev. 2023-02-05.*

**Yes — manifest only** — Supplementaries, Amendments

> Section 5 grants modpack use provided the copy is unmodified, obtained from the authors' own CurseForge or Modrinth pages, and **not directly bundled** in the pack. In-pack credits are explicitly not required. Public redistribution and sale are prohibited.
>
> *Source: bundled LICENSE — Supplementaries Team License v1.5.*
>
> **Unverified:** Moonlight Lib, MmmMmmMmmMmm, Smarter Farmers declare the same license but ship no license file of their own. The same terms are assumed and must be confirmed.

**Yes — non-commercial only** — EntityCulling, NotEnoughAnimations, 3d-Skin-Layers, WaveyCapes

> Grants use, modification and compilation, but **not redistribution** — manifest distribution only. The software may not be used to obtain a commercial advantage or monetary compensation, which rules out monetising the pack. The copyright and permission notice must be reproduced.
>
> *Source: bundled LICENSE — tr7zw Protective License.*

**Ask — see permissions page** — Balm, Waystones, NetherPortalFix, TrashSlot

> All Rights Reserved, but the bundled notice directs to a standing permissions page at `mods.twelveiterations.com/permissions`. Read that page and record the outcome here — it covers the author's whole catalogue, so one reading resolves every entry below.
>
> *Source: bundled LICENSE_* notice.*
>
> **Unverified:** Cooking for Blockheads, Crafting Tweaks declare the same license but ship no license file of their own. The same terms are assumed and must be confirmed.

**Yes — CC0** — AddonsLib

> The jar bundles a full CC0 1.0 text, byte-identical to the one in the author's GitHub repository. The `All Rights Reserved` in its toml and on Modrinth is most likely an unchanged MDK and platform default. Treated as CC0; author confirmation still outstanding.
>
> *Source: bundled LICENSE_AddonsLib — SHA-256 `a2010f34…`.*
>
> **Unverified:** Macaw's Oh The Biomes We've Gone, Macaw's Regions Unexplored declare the same license but ship no license file of their own. The same terms are assumed and must be confirmed.

### Still needing a decision (156 mods)

The homework pile. All Rights Reserved, custom licenses, no-derivatives, non-commercial, or just plain undeclared — nothing in the jar grants us anything, so somebody has to actually ask.

Less scary than the row count suggests: these cluster hard by author. The AurilisDev family alone (Electrodynamics, Nuclear Science, Voltaic, Assembly Line, Ballistix, Blastcraft, Modular Force Fields) is *one* message covering seven mods.

| Mod | License | Family | Links | Modpack use permitted | Explicit permission |
|---|---|---|---|---|---|
| AE2:Crafting Tree | All Rights Reserved | All Rights Reserved | — | | |
| Aether Villages | All Rights Reserved | All Rights Reserved | [Modrinth](https://modrinth.com/mod/aether-villages) | | |
| AlmostUnified | All Rights Reserved | All Rights Reserved | [Modrinth](https://modrinth.com/mod/almostunified) | | |
| Aquaculture 2 | All Rights Reserved | All Rights Reserved | [Modrinth](https://modrinth.com/mod/aquaculture) | | |
| Atlas API | All Rights Reserved | All Rights Reserved | — | | |
| Blue Flame Burning | All Rights Reserved | All Rights Reserved | [Modrinth](https://modrinth.com/mod/blueflame) | | |
| Chipped | All Rights Reserved | All Rights Reserved | [Modrinth](https://modrinth.com/mod/chipped) | | |
| Chroma Carvings | All Rights Reserved | All Rights Reserved | — | | |
| Cobblegen Galore | All Rights Reserved | All Rights Reserved | — | | |
| Colorwheel Patcher | All Rights Reserved | All Rights Reserved | [Modrinth](https://modrinth.com/mod/colorwheel-patcher) | | |
| Connected Glass | All Rights Reserved | All Rights Reserved | [Modrinth](https://modrinth.com/mod/connected-glass) | | |
| Crafting On A Stick | All Rights Reserved | All Rights Reserved | [Modrinth](https://modrinth.com/mod/crafting-on-a-stick) | | |
| Create: Applied Kinetics | All Rights Reserved | All Rights Reserved | [Modrinth](https://modrinth.com/mod/create-applied-kinetics) | | |
| Create: Copycats+ | All Rights Reserved | All Rights Reserved | [Modrinth](https://modrinth.com/mod/copycats) | | |
| Creeper Overhaul | All Rights Reserved | All Rights Reserved | [Modrinth](https://modrinth.com/mod/creeper-overhaul) | | |
| Dis-Enchanting Table | All Rights Reserved | All Rights Reserved | [Modrinth](https://modrinth.com/mod/dis-enchanting-table) | | |
| Dungeons and Taverns | All Rights Reserved | All Rights Reserved | [Modrinth](https://modrinth.com/mod/dungeons-and-taverns) | | |
| Durability Tooltip | All Rights Reserved | All Rights Reserved | [Modrinth](https://modrinth.com/mod/durability-tooltip) | | |
| Dyenamics | All Rights Reserved | All Rights Reserved | — | | |
| Dyenamics and Friends | All Rights Reserved | All Rights Reserved | — | | |
| Easy Villagers | All Rights Reserved | All Rights Reserved | [Modrinth](https://modrinth.com/mod/easy-villagers) | | |
| Enderman Overhaul | All Rights Reserved | All Rights Reserved | [Modrinth](https://modrinth.com/mod/enderman-overhaul) | | |
| Energy Meter | All Rights Reserved | All Rights Reserved | [Modrinth](https://modrinth.com/mod/energymeter) | | |
| Entangled | All Rights Reserved | All Rights Reserved | [Modrinth](https://modrinth.com/mod/entangled) | | |
| Everything Bugs | All Rights Reserved | All Rights Reserved | — | | |
| Everything is Copper | All Rights Reserved | All Rights Reserved | — | | |
| Explore Ruins Aether | All Rights Reserved | All Rights Reserved | [Modrinth](https://modrinth.com/mod/explore-ruins-aether) | | |
| Explorify | All Rights Reserved | All Rights Reserved | [Modrinth](https://modrinth.com/mod/explorify) | | |
| Forbidden Arcanus | All Rights Reserved | All Rights Reserved | [Modrinth](https://modrinth.com/mod/forbidden-arcanus) | | |
| Formations | All Rights Reserved | All Rights Reserved | [Modrinth](https://modrinth.com/mod/formations) | | |
| Formations Nether | All Rights Reserved | All Rights Reserved | [Modrinth](https://modrinth.com/mod/formations-nether) | | |
| Formations Overworld | All Rights Reserved | All Rights Reserved | [Modrinth](https://modrinth.com/mod/formations-overworld) | | |
| FTB Chunks | All Rights Reserved | All Rights Reserved | — | | |
| FTB Essentials | All Rights Reserved | All Rights Reserved | — | | |
| FTB Filter System | All Rights Reserved | All Rights Reserved | [Home](https://www.curseforge.com/minecraft/mc-mods/ftb-filter-system) | | |
| FTB Jei Extras | All Rights Reserved | All Rights Reserved | — | | |
| FTB Library | All Rights Reserved | All Rights Reserved | — | | |
| FTB Quests | All Rights Reserved | All Rights Reserved | — | | |
| FTB Ranks | All Rights Reserved | All Rights Reserved | — | | |
| FTB Teams | All Rights Reserved | All Rights Reserved | — | | |
| FTB Ultimine | All Rights Reserved | All Rights Reserved | — | | |
| Fusion | All Rights Reserved | All Rights Reserved | [Modrinth](https://modrinth.com/mod/fusion-connected-textures) | | |
| Generator Galore | All Rights Reserved | All Rights Reserved | — | | |
| GlitchCore | All Rights Reserved | All Rights Reserved | [Modrinth](https://modrinth.com/mod/glitchcore) | | |
| Gravestone Mod | All Rights Reserved | All Rights Reserved | [Modrinth](https://modrinth.com/mod/gravestone-mod) | | |
| Hellish Trials | All Rights Reserved | All Rights Reserved | [Modrinth](https://modrinth.com/mod/hellish-trials) | | |
| Integrated API | All Rights Reserved | All Rights Reserved | [Modrinth](https://modrinth.com/mod/integrated-api) | | |
| Integrated Cataclysm | All Rights Reserved | All Rights Reserved | [Modrinth](https://modrinth.com/mod/integrated-catalcysm) | | |
| Integrated Dungeons and Structures | All Rights Reserved | All Rights Reserved | [Modrinth](https://modrinth.com/mod/idas) | | |
| Iron's Gems 'n Jewelry | All Rights Reserved | All Rights Reserved | — | | |
| Iron's Lib | All Rights Reserved | All Rights Reserved | [Modrinth](https://modrinth.com/mod/irons-lib) | | |
| Iron's Spells 'n Spellbooks | All Rights Reserved | All Rights Reserved | [Modrinth](https://modrinth.com/mod/irons-spells-n-spellbooks) · [Terms](https://github.com/iron431/Irons-Spells-n-Spellbooks#readme) | | |
| Just Enough Archaeology | All Rights Reserved | All Rights Reserved | [Modrinth](https://modrinth.com/mod/just-enough-archaeology) | | |
| Just Enough Effects Descriptions | All Rights Reserved | All Rights Reserved | [Modrinth](https://modrinth.com/mod/just-enough-effect-descriptions-jeed) | | |
| legendary_monsters | All Rights Reserved | All Rights Reserved | [Modrinth](https://modrinth.com/mod/legendary-monsters) | | |
| Macaw's Bridges | All Rights Reserved | All Rights Reserved | [Modrinth](https://modrinth.com/mod/macaws-bridges) | | |
| Macaw's Furniture | All Rights Reserved | All Rights Reserved | [Modrinth](https://modrinth.com/mod/macaws-furniture) | | |
| Macaw's Holidays | All Rights Reserved | All Rights Reserved | [Modrinth](https://modrinth.com/mod/macaws-holidays) | | |
| Macaw's Lights and Lamps | All Rights Reserved | All Rights Reserved | [Modrinth](https://modrinth.com/mod/macaws-lights-and-lamps) | | |
| Macaw's Paintings | All Rights Reserved | All Rights Reserved | [Modrinth](https://modrinth.com/mod/macaws-paintings) | | |
| Macaw's Roofs | All Rights Reserved | All Rights Reserved | [Modrinth](https://modrinth.com/mod/macaws-roofs) | | |
| Macaw's Stairs and Balconies | All Rights Reserved | All Rights Reserved | [Modrinth](https://modrinth.com/mod/macaws-stairs) | | |
| Macaw's Windows | All Rights Reserved | All Rights Reserved | [Modrinth](https://modrinth.com/mod/macaws-windows) | | |
| Mahou Tsukai | All Rights Reserved | All Rights Reserved | [Modrinth](https://modrinth.com/mod/mahou-tsukai) | | |
| OctoLib | All Rights Reserved | All Rights Reserved | [Modrinth](https://modrinth.com/mod/shatterbyte-lib) | | |
| Oh The Biomes We've Gone | All Rights Reserved | All Rights Reserved | [Modrinth](https://modrinth.com/mod/oh-the-biomes-weve-gone) | | |
| Pam's HarvestCraft - Crops | All Rights Reserved | All Rights Reserved | [Modrinth](https://modrinth.com/mod/pams-harvestcraft-2-crops) | | |
| Pam's HarvestCraft - Food Core | All Rights Reserved | All Rights Reserved | [Modrinth](https://modrinth.com/mod/pams-harvestcraft-2-food-core) | | |
| Pam's HarvestCraft - Food Extended | All Rights Reserved | All Rights Reserved | [Modrinth](https://modrinth.com/mod/pams-harvestcraft-2-food-extended) | | |
| Pam's HarvestCraft - Trees | All Rights Reserved | All Rights Reserved | [Modrinth](https://modrinth.com/mod/pams-harvestcraft-2-trees) | | |
| Productive Bees | All Rights Reserved | All Rights Reserved | — | | |
| Productive Farming | All Rights Reserved | All Rights Reserved | — | | |
| Productive Metalworks | All Rights Reserved | All Rights Reserved | — | | |
| Productive Trees | All Rights Reserved | All Rights Reserved | — | | |
| Pylons | All Rights Reserved | All Rights Reserved | [Modrinth](https://modrinth.com/mod/pylons) | | |
| Rechiseled | All Rights Reserved | All Rights Reserved | [Modrinth](https://modrinth.com/mod/rechiseled) | | |
| Rechiseled: Create | All Rights Reserved | All Rights Reserved | [Modrinth](https://modrinth.com/mod/rechiseled-create) | | |
| Relics | All Rights Reserved | All Rights Reserved | [Modrinth](https://modrinth.com/mod/relics-mod) | | |
| reliquified_artifacts | All Rights Reserved | All Rights Reserved | [Modrinth](https://modrinth.com/mod/reliquified-artifacts) | | |
| Sophisticated Backpacks | All Rights Reserved | All Rights Reserved | [Modrinth](https://modrinth.com/mod/sophisticated-backpacks) | | |
| Sophisticated Backpacks Create Integration | All Rights Reserved | All Rights Reserved | [Modrinth](https://modrinth.com/mod/sophisticated-backpacks-create-integration) | | |
| Sophisticated Core | All Rights Reserved | All Rights Reserved | [Modrinth](https://modrinth.com/mod/sophisticated-core) | | |
| Sophisticated Storage | All Rights Reserved | All Rights Reserved | [Modrinth](https://modrinth.com/mod/sophisticated-storage) | | |
| Sophisticated Storage Create Integration | All Rights Reserved | All Rights Reserved | [Modrinth](https://modrinth.com/mod/sophisticated-storage-create-integration) | | |
| Sparkweave Engine | All Rights Reserved | All Rights Reserved | [Modrinth](https://modrinth.com/mod/sparkweave) | | |
| SuperMartijn642's Config Library | All Rights Reserved | All Rights Reserved | [Modrinth](https://modrinth.com/mod/supermartijn642s-config-lib) | | |
| SuperMartijn642's Core Lib | All Rights Reserved | All Rights Reserved | [Modrinth](https://modrinth.com/mod/supermartijn642s-core-lib) | | |
| The Bumblezone | All Rights Reserved | All Rights Reserved | [Modrinth](https://modrinth.com/mod/the-bumblezone) | | |
| The Undergarden | All Rights Reserved | All Rights Reserved | [Modrinth](https://modrinth.com/mod/the-undergarden) | | |
| Tough As Nails | All Rights Reserved | All Rights Reserved | [Modrinth](https://modrinth.com/mod/tough-as-nails) | | |
| Towntalk | All Rights Reserved | All Rights Reserved | — | | |
| Trash Cans | All Rights Reserved | All Rights Reserved | [Modrinth](https://modrinth.com/mod/trash-cans) | | |
| Tree Tap | All Rights Reserved | All Rights Reserved | — | | |
| Utilitarian | All Rights Reserved | All Rights Reserved | [Modrinth](https://modrinth.com/mod/utilitarian) | | |
| Wireless Chargers | All Rights Reserved | All Rights Reserved | [Modrinth](https://modrinth.com/mod/wireless-chargers) | | |
| Xaero's Minimap | All Rights Reserved | All Rights Reserved | [Modrinth](https://modrinth.com/mod/xaeros-minimap) | | |
| Xaero's World Map | All Rights Reserved | All Rights Reserved | [Modrinth](https://modrinth.com/mod/xaeros-world-map) | | |
| XyCraft Core | All Rights Reserved | All Rights Reserved | — | | |
| XyCraft Machines | All Rights Reserved | All Rights Reserved | — | | |
| XyCraft Override | All Rights Reserved | All Rights Reserved | — | | |
| XyCraft World | All Rights Reserved | All Rights Reserved | — | | |
| Advancement Plaques | CC BY-NC-ND | CC (no derivatives) | [Modrinth](https://modrinth.com/mod/advancement-plaques) | | |
| ChoiceTheorem's Overhauled Village | CC BY-NC-ND | CC (no derivatives) | [Modrinth](https://modrinth.com/mod/ct-overhaul-village) | | |
| Iceberg | CC BY-NC-ND | CC (no derivatives) | [Modrinth](https://modrinth.com/mod/iceberg) | | |
| Item Borders | CC BY-NC-ND | CC (no derivatives) | [Modrinth](https://modrinth.com/mod/item-borders) | | |
| L_Ender's Cataclysm 1.21.1 | CC BY-NC-ND | CC (no derivatives) | [Modrinth](https://modrinth.com/mod/l_enders-cataclysm) | | |
| Legendary Tooltips | CC BY-NC-ND | CC (no derivatives) | [Modrinth](https://modrinth.com/mod/legendary-tooltips) | | |
| Living Things | CC BY-NC-ND | CC (no derivatives) | [Modrinth](https://modrinth.com/mod/living-things) | | |
| Prism | CC BY-NC-ND | CC (no derivatives) | [Modrinth](https://modrinth.com/mod/prism-lib) | | |
| Classic Pipes | CC BY-NC-SA | CC (non-commercial) | [Modrinth](https://modrinth.com/mod/classic-pipes) · [Terms](https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode.txt) | | |
| Explorer's Compass | CC BY-NC-SA | CC (non-commercial) | [Modrinth](https://modrinth.com/mod/explorers-compass) | | |
| Jade | CC BY-NC-SA | CC (non-commercial) | [Modrinth](https://modrinth.com/mod/jade) | | |
| Nature's Compass | CC BY-NC-SA | CC (non-commercial) | [Modrinth](https://modrinth.com/mod/natures-compass) | | |
| Patchouli | CC BY-NC-SA | CC (non-commercial) | [Modrinth](https://modrinth.com/mod/patchouli) | | |
| Quark | CC BY-NC-SA | CC (non-commercial) | [Modrinth](https://modrinth.com/mod/quark) | | |
| Stellaris | CC BY-NC-SA | CC (non-commercial) | [Modrinth](https://modrinth.com/mod/stellaris) | | |
| The Roads More Travelled | CC BY-NC | CC (non-commercial) | [Modrinth](https://modrinth.com/mod/the-roads-more-travelled) | | |
| Zeta | CC BY-NC-SA | CC (non-commercial) | [Modrinth](https://modrinth.com/mod/zeta) · [Terms](https://github.com/VazkiiMods/Zeta/blob/main/LICENSE.md) | | |
| Advanced Netherite | LicenseRef-Custom | Custom | [Modrinth](https://modrinth.com/mod/advanced-netherite) · [Terms](https://github.com/Autovw/AdvancedNetherite/blob/1.18.X/LICENSE) | | |
| Assembly Line | LicenseRef-AURILISDEV-LICENSE-1.0.1 | Custom | [Modrinth](https://modrinth.com/mod/assembly-lines) · [Terms](https://github.com/aurilisdev/Assembly-Line/blob/1.19.2/LICENSE.txt) | | |
| Ballistix | LicenseRef-AURILISDEV-LICENSE-1.02 | Custom | [Modrinth](https://modrinth.com/mod/ballistix) · [Terms](https://github.com/aurilisdev/Electrodynamics/blob/1.20/LICENSE.txt) | | |
| Better Advancements | LicenseRef-Dont-Be-a-Jerk | Custom | [Modrinth](https://modrinth.com/mod/better-advancements) · [Terms](https://github.com/way2muchnoise/BetterAdvancements/blob/master/LICENSE.md) | | |
| Better Compatibility Checker | Custom | Custom | [Modrinth](https://modrinth.com/mod/better-compatibility-checker) | | |
| Blastcraft | LicenseRef-AURILISDEV-LICENSE-1.0.2 | Custom | [Modrinth](https://modrinth.com/mod/blastcraft) · [Terms](https://github.com/aurilisdev/Electrodynamics/blob/1.20/LICENSE.txt) | | |
| Brandon's Core | LicenseRef-CoFH-Dont-Be-a-Jerk-License | Custom | [Modrinth](https://modrinth.com/mod/brandons-core) · [Terms](https://github.com/Draconic-Inc/BrandonsCore/blob/master/LICENSE.md) | | |
| CC: Tweaked | LicenseRef-CCPL | Custom | [Modrinth](https://modrinth.com/mod/cc-tweaked) · [Terms](https://github.com/cc-tweaked/CC-Tweaked/blob/mc-1.16.x/LICENSE) | | |
| CosmeticArmorReworked | Minecraft Mod Public License 1.0.1 | Custom | — | | |
| Crash Assistant | LicenseRef-LicenseRef-KostromDan-MML-1.1.3 | Custom | [Modrinth](https://modrinth.com/mod/crash-assistant) · [Terms](https://github.com/KostromDan/Crash-Assistant/blob/1.19-1.20.1/LICENSE.md) | | |
| Create | LicenseRef-Create-Mod-License | Custom | [Modrinth](https://modrinth.com/mod/create) · [Terms](https://github.com/Creators-of-Create/Create/blob/HEAD/LICENSE.md) | | |
| Create Big Cannons | LicenseRef-Create-Big-Cannons-License | Custom | [Modrinth](https://modrinth.com/mod/create-big-cannons) · [Terms](https://github.com/Cannoneers-of-Create/CreateBigCannons/blob/0b3e23456f38bac359112d82d6aad1b5430c04d1/LICENSE.md) | | |
| Create Slice & Dice | LicenseRef-Custom | Custom | [Modrinth](https://modrinth.com/mod/slice-and-dice) · [Terms](https://github.com/PssbleTrngle/SliceAndDice/blob/1.19.x/LICENSE.txt) | | |
| Create: Dreams n' Desires | LicenseRef-MIT-Code-AND-ARR-Art | Custom | [Modrinth](https://modrinth.com/mod/create-dreams-and-desires) | | |
| Cupboard mod | ARR | Custom | — | | |
| Design n' Decor | LicenseRef-MIT-Code-AND-ARR-Art | Custom | [Modrinth](https://modrinth.com/mod/create-design-n-decor) | | |
| Draconic Evolution | LicenseRef-CoFH-Dont-Be-a-Jerk-License | Custom | [Modrinth](https://modrinth.com/mod/draconic-evolution) · [Terms](https://github.com/Draconic-Inc/Draconic-Evolution/blob/master/LICENSE.md) | | |
| Drippy Early Loading Module | LicenseRef-DSMSLv3 | Custom | [Modrinth](https://modrinth.com/mod/drippy-early-loading-module) · [Terms](https://github.com/Keksuccino/Drippy-Loading-Screen/blob/main/LICENSE.md) | | |
| Drippy Loading Screen | LicenseRef-DSMSLv3 | Custom | [Modrinth](https://modrinth.com/mod/drippy-loading-screen) · [Terms](https://github.com/Keksuccino/Drippy-Loading-Screen/blob/main/LICENSE.md) | | |
| Electrodynamics | LicenseRef-AURILISDEV-LICENSE-1.0.2 | Custom | [Modrinth](https://modrinth.com/mod/electrodynamics) · [Terms](https://github.com/aurilisdev/Electrodynamics/blob/1.20/LICENSE.txt) | | |
| FancyMenu | LicenseRef-DSMSLv3 | Custom | [Modrinth](https://modrinth.com/mod/fancymenu) · [Terms](https://github.com/Keksuccino/FancyMenu/blob/master/LICENSE.md) | | |
| Handcrafted | LicenseRef-Terrarium-Licence | Custom | [Modrinth](https://modrinth.com/mod/handcrafted) · [Terms](https://github.com/terrarium-earth/Handcrafted/blob/1.19.2/LICENSE) | | |
| Immersive Engineering | LicenseRef-Custom | Custom | [Modrinth](https://modrinth.com/mod/immersiveengineering) · [Terms](https://github.com/BluSunrize/ImmersiveEngineering/blob/1.16.5/LICENSE) | | |
| IntegratedScripting | Custom | Custom | [Modrinth](https://modrinth.com/mod/integrated-scripting) | | |
| Just Enough Resources | LicenseRef-Dont-Be-a-Jerk | Custom | [Modrinth](https://modrinth.com/mod/just-enough-resources-jer) · [Terms](https://github.com/way2muchnoise/JustEnoughResources/blob/master/LICENSE.md) | | |
| Just Zoom | LicenseRef-DSMSLv2 | Custom | [Modrinth](https://modrinth.com/mod/just-zoom) · [Terms](https://github.com/Keksuccino/JustZoom/blob/main/LICENSE.md) | | |
| memorysettings mod | ARR | Custom | — | | |
| Modular Force Fields | LicenseRef-AURILISDEV-LICENSE-1.0.2 | Custom | [Modrinth](https://modrinth.com/mod/modular-force-field-systems) · [Terms](https://github.com/aurilisdev/Electrodynamics/blob/1.20/LICENSE.txt) | | |
| MonoLib | Custom | Custom | [Modrinth](https://modrinth.com/mod/monolib) · [Terms](https://unlicense.org/) | | |
| No Chat Reports | Custom | Custom | [Modrinth](https://modrinth.com/mod/no-chat-reports) | | |
| Nuclear Science | LicenseRef-AURILISDEV-LICENSE-1.0.2 | Custom | [Modrinth](https://modrinth.com/mod/nuclear-science) · [Terms](https://github.com/aurilisdev/Electrodynamics/blob/1.20/LICENSE.txt) | | |
| Protect Your Moa | LicenseRef-Custom | Custom | [Modrinth](https://modrinth.com/mod/aether-protect-your-moa) · [Terms](https://github.com/The-Aether-Team/Protect-Your-Moa#scroll-license-information) | | |
| Sodium | LicenseRef-Polyform-Shield-1.0.0 | Custom | [Modrinth](https://modrinth.com/mod/sodium) · [Terms](https://github.com/CaffeineMC/sodium/blob/dev/LICENSE.md) | | |
| SpiffyHUD | LicenseRef-DSMSLv3 | Custom | [Modrinth](https://modrinth.com/mod/spiffyhud) · [Terms](https://github.com/Keksuccino/Spiffy-HUD/blob/main/LICENSE.md) | | |
| The Aether | LicenseRef-Custom | Custom | [Modrinth](https://modrinth.com/mod/aether) · [Terms](https://github.com/The-Aether-Team/The-Aether#scroll-license-information) | | |
| Valhelsia Core | LicenseRef-Custom | Custom | [Modrinth](https://modrinth.com/mod/valhelsia-core) | | |
| Variants&Ventures | LicenseRef-CC-BY-NC-ND-4.0 | Custom | [Modrinth](https://modrinth.com/mod/variants-and-ventures) · [Terms](https://raw.githubusercontent.com/Faboslav/variants-and-ventures/master/LICENSE.txt) | | |
| Voltaic | LicenseRef-AURILISDEV-LICENSE-1.0.2 | Custom | [Modrinth](https://modrinth.com/mod/voltaic) · [Terms](https://github.com/aurilisdev/Electrodynamics/blob/1.20/LICENSE.txt) | | |

---

## All bundled mods

All 496 mods in the pack, alphabetically. **Modpack use permitted** is pre-filled only where a bundled license file establishes it; the rest is for the team to complete.

| Mod | Author(s) | License (jar) | License (Modrinth) | Bundled file | Links | Modpack use permitted | Explicit permission |
|---|---|---|---|---|---|---|---|
| 3d-Skin-Layers | tr7zw | tr7zw Protective License | LicenseRef-tr7zw-Protective-Licen… | MIT | [Modrinth](https://modrinth.com/mod/3dskinlayers) · [Terms](https://github.com/tr7zw/3d-Skin-Layers/blob/1.17/LICENSE) | Yes — non-commercial only | |
| Accelerated Decay | ErrorMikey | GPL-3.0 ⚠️ | LGPL-3.0 | — | [Modrinth](https://modrinth.com/mod/accelerated-decay) |  | |
| Ace's Spell Utils | Ace The Eldritch King | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/aces-spell-utils) |  | |
| Additional Lights | mgen256 | MIT | — | — | [Home](https://www.curseforge.com/minecraft/mc-mods/additional-lights) |  | |
| AddonsLib | Samlegamer | All Rights Reserved | All Rights Reserved | CC0-1.0 | [Modrinth](https://modrinth.com/mod/addonslib) | Yes — CC0 | |
| Advanced AE | Pedroksl | LGPL-3.0 | LGPL-3.0 | — | [Modrinth](https://modrinth.com/mod/advancedae) |  | |
| Advanced Netherite | Autovw | GPL-3.0 ⚠️ | LicenseRef-Custom | — | [Modrinth](https://modrinth.com/mod/advanced-netherite) · [Terms](https://github.com/Autovw/AdvancedNetherite/blob/1.18.X/LICENSE) |  | |
| Advanced Peripherals | Srendi | All Rights Reserved ⚠️ | Apache-2.0 | — | [Modrinth](https://modrinth.com/mod/advancedperipherals) |  | |
| Advancement Plaques | Grend | CC BY-NC-ND | CC BY-NC-ND | — | [Modrinth](https://modrinth.com/mod/advancement-plaques) |  | |
| AE2 Import Export Card | Ultramega | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/ae2-import-export-card) |  | |
| AE2 JEI Integration | Tamaized, mezz | LGPL-3.0 | — | — | — |  | |
| AE2:Crafting Tree | Neuvillette | All Rights Reserved | — | — | — |  | |
| AE2NetworkAnalyzer | GlodBlock | LGPL-3.0 | — | — | [Home](https://github.com/GlodBlock/ExtendedAE) |  | |
| AE2WTLib | mari_023, Ridanisaurus | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/applied-energistics-2-wireless-terminals) |  | |
| AEInfinityBooster | Hexeption | LGPL | LGPL-3.0 | — | [Modrinth](https://modrinth.com/mod/aeinfinitybooster) |  | |
| Aether Villages | Aureljz, DiamondTown | All Rights Reserved | All Rights Reserved | — | [Modrinth](https://modrinth.com/mod/aether-villages) |  | |
| All The Leaks | Uncandango | MIT | — | — | — |  | |
| Almanac | frikinjay | LGPL-3.0 | LGPL-3.0 | — | [Modrinth](https://modrinth.com/mod/almanac) |  | |
| AlmostUnified | Almost Reliable | All Rights Reserved | All Rights Reserved | — | [Modrinth](https://modrinth.com/mod/almostunified) |  | |
| AmbientSounds | CreativeMD | LGPL-3.0 | LGPL-3.0 | — | [Modrinth](https://modrinth.com/mod/ambientsounds) |  | |
| Amendments | MehVahdJukaar, Plantkillable | Supplementaries Team License v.1.5 | LicenseRef-Supplementaries-Team-L… | All Rights Reserved | [Modrinth](https://modrinth.com/mod/amendments) · [Terms](https://github.com/MehVahdJukaar/Supplementaries-Team-License/blob/main/LICENSE.md) | Yes — manifest only | |
| Aperture Innovations | mistersecret312 | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/aperture-innovations) |  | |
| Apotheosis | Shadows_of_Fire | MIT | — | — | [Home](https://www.curseforge.com/minecraft/mc-mods/apotheosis) |  | |
| Apothic Attributes | Shadows_of_Fire | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/apothic-attributes) |  | |
| Apothic Enchanting | Shadows_of_Fire | MIT | — | — | — |  | |
| Apothic Spawners | Shadows_of_Fire | MIT | — | — | — |  | |
| Applied Energistics 2 | Team AppliedEnergistics | Undeclared ⚠️ | LicenseRef-Multiple | Apache-2.0 | [Modrinth](https://modrinth.com/mod/ae2) · [Terms](https://github.com/AppliedEnergistics/Applied-Energistics-2#license) |  | |
| Applied Mekanistics | ramidzkh | Undeclared ⚠️ | LGPL-3.0 | — | [Modrinth](https://modrinth.com/mod/applied-mekanistics) |  | |
| AppliedE | 90 | LGPL-3.0 | LGPL-3.0 | LGPL-3.0 | [Modrinth](https://modrinth.com/mod/appliede) |  | |
| AppliedFlux | GlodBlock | LGPL-3.0 | LGPL-3.0 | — | [Modrinth](https://modrinth.com/mod/appflux) |  | |
| Aquaculture 2 | Shadowclaimer, Girafi | All Rights Reserved | All Rights Reserved | — | [Modrinth](https://modrinth.com/mod/aquaculture) |  | |
| Architectury | shedaniel | LGPL-3.0 | LGPL-3.0 | — | [Modrinth](https://modrinth.com/mod/architectury-api) |  | |
| Ars Additions | Jarva | LGPL-3.0 | LGPL-3.0 | — | [Modrinth](https://modrinth.com/mod/ars-additions) |  | |
| Ars Controle | Qther | LGPL-3.0 | LGPL-3.0 | — | [Modrinth](https://modrinth.com/mod/ars-controle) |  | |
| Ars Creo | Bailey | LGPL-3.0 ⚠️ | GPL-3.0 | — | [Modrinth](https://modrinth.com/mod/ars-creo) |  | |
| Ars Elemancy | Lyrellion | LGPL-3.0 | — | — | [Home](https://www.curseforge.com/minecraft/mc-mods/ars-elemancy) |  | |
| Ars Elemental | Alexthw | LGPL-3.0 | — | — | [Home](https://www.curseforge.com/minecraft/mc-mods/ars-elemental-elemental-spell-foci) |  | |
| Ars Nouveau | Bailey Hollingsworth | GPL-3.0 | GPL-3.0 | Apache-2.0 | [Modrinth](https://modrinth.com/mod/ars-nouveau) |  | |
| Ars Nouveau's Flavors & Delight | lcy0x1 | LGPL-2.1 | LGPL-2.1 | — | [Modrinth](https://modrinth.com/mod/arsdelight) |  | |
| Ars Ocultas | mystchonky | LGPL-3.0 | LGPL-3.0 | — | [Modrinth](https://modrinth.com/mod/ars-ocultas) |  | |
| Ars Technica | zeroregard | LGPL-3.0 | — | — | — |  | |
| Ars Unification | Qther | LGPL-3.0 | LGPL-3.0 | — | [Modrinth](https://modrinth.com/mod/ars-unification) · [Terms](https://github.com/Vonr/Ars-Unification/blob/master/LICENSE.txt) |  | |
| Ars Énergistique | 90, dkmk100 | LGPL-3.0 | LGPL-3.0 | — | [Modrinth](https://modrinth.com/mod/ars-energistique) |  | |
| Artifacts | ochotonida | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/artifacts) |  | |
| Assembly Line | aurilisdev, skip999 | All Rights Reserved ⚠️ | LicenseRef-AURILISDEV-LICENSE-1.0… | — | [Modrinth](https://modrinth.com/mod/assembly-lines) · [Terms](https://github.com/aurilisdev/Assembly-Line/blob/1.19.2/LICENSE.txt) |  | |
| Athena | ThatGravyBoat | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/athena-ctm) |  | |
| Atlas API | Iron431 | All Rights Reserved | — | — | — |  | |
| AttributeFix | Darkhax | LGPL-2.1 | LGPL-2.1 | LGPL-3.0 | [Modrinth](https://modrinth.com/mod/attributefix) |  | |
| Auroras | Verph | BSD | BSD | — | [Modrinth](https://modrinth.com/mod/auroras) |  | |
| Auth Me | axieum | MIT | MIT | MIT | [Modrinth](https://modrinth.com/mod/auth-me) |  | |
| Bad Wither No Cookie Reloaded | Kreezxil, Eleksploded | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/bad-wither-no-cookie) |  | |
| Ballistix | aurilisdev, skip999 | All Rights Reserved ⚠️ | LicenseRef-AURILISDEV-LICENSE-1.02 | — | [Modrinth](https://modrinth.com/mod/ballistix) · [Terms](https://github.com/aurilisdev/Electrodynamics/blob/1.20/LICENSE.txt) |  | |
| Balm | BlayTheNinth | All Rights Reserved | All Rights Reserved | All Rights Reserved | [Modrinth](https://modrinth.com/mod/balm) · [Terms](https://mods.twelveiterations.com/permissions) | Ask — see permissions page | |
| Baubley Heart Canisters | Traverse_Joe | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/baubley-heart-canisters) |  | |
| Better Advancements | way2muchnoise | \ | LicenseRef-Dont-Be-a-Jerk | — | [Modrinth](https://modrinth.com/mod/better-advancements) · [Terms](https://github.com/way2muchnoise/BetterAdvancements/blob/master/LICENSE.md) |  | |
| Better Archeology | Pandarix | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/better-archeology) |  | |
| Better Beds | TeamMidnightDust, Motschen | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/better-beds) |  | |
| Better Compatibility Checker | Gaz(Gaz492) | All Rights Reserved | All Rights Reserved | Custom | [Modrinth](https://modrinth.com/mod/better-compatibility-checker) |  | |
| BetterF3 | TreyRuffy and cominixo | MIT | MIT | MIT | [Modrinth](https://modrinth.com/mod/betterf3) |  | |
| BetterGrassify | UltimatChamp, JayemCeekay | Apache-2.0 | Apache-2.0 | — | [Modrinth](https://modrinth.com/mod/bettergrassify) · [Terms](https://github.com/UltimatChamp/BetterGrassify/raw/main/LICENSE) |  | |
| Bibliobiomes Legacy | IchHabeHunger54 | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/bibliobiomes-legacy) |  | |
| Bibliocraft Legacy | IchHabeHunger54, Minecraftschurli | MIT | MIT | MIT | [Modrinth](https://modrinth.com/mod/bibliocraft-legacy) |  | |
| Bibliowoods Legacy | IchHabeHunger54 | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/bibliowoods-legacy) |  | |
| Blastcraft | aurilisdev | All Rights Reserved ⚠️ | LicenseRef-AURILISDEV-LICENSE-1.0… | — | [Modrinth](https://modrinth.com/mod/blastcraft) · [Terms](https://github.com/aurilisdev/Electrodynamics/blob/1.20/LICENSE.txt) |  | |
| Blue Flame Burning | LobsterJonn | All Rights Reserved | All Rights Reserved | — | [Modrinth](https://modrinth.com/mod/blueflame) |  | |
| Bookshelf | Darkhax | LGPL-2.1 | LGPL-2.1 | LGPL-3.0 | [Modrinth](https://modrinth.com/mod/bookshelf-lib) |  | |
| BotanyPots | Darkhax | LGPL-2.1 | LGPL-2.1 | LGPL-3.0 | [Modrinth](https://modrinth.com/mod/botany-pots) |  | |
| BotanyPots-Mystical | Darkhax | LGPL-2.1 | LGPL-2.1 | LGPL-3.0 | [Modrinth](https://modrinth.com/mod/botany-pots-mystical-agriculture-compat) |  | |
| BotanyTrees | Darkhax | LGPL-2.1 | LGPL-2.1 | LGPL-3.0 | [Modrinth](https://modrinth.com/mod/botany-trees) |  | |
| Brandon's Core | brandon3055 | CoFH \ | LicenseRef-CoFH-Dont-Be-a-Jerk-Li… | — | [Modrinth](https://modrinth.com/mod/brandons-core) · [Terms](https://github.com/Draconic-Inc/BrandonsCore/blob/master/LICENSE.md) |  | |
| Bridging Mod | CG360 | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/bridging-mod) · [Terms](https://github.com/CloudG360/BridgingMod/blob/latest/LICENSE) |  | |
| Building Gadgets 2 | Direwolf20 | MIT | — | — | [Home](https://github.com/Direwolf20-MC/BuildingGadgets2) |  | |
| Cable Tiers | Ultramega | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/cable-tiers) |  | |
| Caelus API | Illusive Soulworks | LGPL-3.0 | LGPL-3.0 | GPL-3.0+LGPL-3.0 | [Modrinth](https://modrinth.com/mod/caelus) |  | |
| Calm The Leaks | Extra_Special_K, Ginger1y, Manialate, Supremepringle | MIT | — | — | [Home](https://unbound.creatopia.uk) |  | |
| Carry Me | Rok | Apache-2.0 | Apache-2.0 | — | [Modrinth](https://modrinth.com/mod/carry-me) |  | |
| Carry On | Tschipp, PurpliciousCow | LGPL-3.0 | LGPL-3.0 | LGPL-3.0 | [Modrinth](https://modrinth.com/mod/carry-on) |  | |
| Catalogue | MrCrayfish | MIT | — | MIT | [Home](https://mrcrayfish.com/mods?id=catalogue) |  | |
| CC: Tweaked | Daniel Ratcliffe, Aaron Mills, SquidDev | ComputerCraft Public License (htt… | LicenseRef-CCPL | — | [Modrinth](https://modrinth.com/mod/cc-tweaked) · [Terms](https://github.com/cc-tweaked/CC-Tweaked/blob/mc-1.16.x/LICENSE) |  | |
| Chat Heads | dzwdz, Fourmisain | MPL-2.0 | MPL-2.0 | — | [Modrinth](https://modrinth.com/mod/chat-heads) |  | |
| Chefs Delight | Redstone Games | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/chefs-delight) |  | |
| Chipped | Alex Nijjar, Grimbop, Kekie6, ThatGravyBoat | Terrarium License ⚠️ | All Rights Reserved | — | [Modrinth](https://modrinth.com/mod/chipped) |  | |
| chisels-and-bits | chisels-and-bits | MIT | — | — | — |  | |
| ChoiceTheorem's Overhauled Village | ChoiceTheorem | CC BY-NC-ND | CC BY-NC-ND | — | [Modrinth](https://modrinth.com/mod/ct-overhaul-village) |  | |
| Chroma Carvings | LobsterJonn | All Rights Reserved | — | — | — |  | |
| Classic Pipes | Jagm | CC BY-NC-SA | CC BY-NC-SA | — | [Modrinth](https://modrinth.com/mod/classic-pipes) · [Terms](https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode.txt) |  | |
| Cloth Config v15 API | shedaniel | LGPL-3.0 | LGPL-3.0 | LGPL-3.0 | [Modrinth](https://modrinth.com/mod/cloth-config) |  | |
| Clumps | Jared | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/clumps) |  | |
| Cobblegen Galore | LobsterJonn | All Rights Reserved | — | — | — |  | |
| CodeChicken Lib | ChickenBones, covers1624 | LGPL-2.1 | LGPL-2.1 | LGPL-3.0 | [Modrinth](https://modrinth.com/mod/codechicken-lib) |  | |
| Colorful Hearts | Terrails | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/colorful-hearts) |  | |
| Colorwheel | djefrey | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/colorwheel) |  | |
| Colorwheel Patcher | djefrey | ARR ⚠️ | All Rights Reserved | — | [Modrinth](https://modrinth.com/mod/colorwheel-patcher) |  | |
| Comforts | Illusive Soulworks | LGPL-3.0 | LGPL-3.0 | GPL-3.0+LGPL-3.0 | [Modrinth](https://modrinth.com/mod/comforts) |  | |
| Common Networking | Mysticdrew | MIT | MIT | MIT | [Modrinth](https://modrinth.com/mod/common-network) |  | |
| CommonCapabilities | rubensworks (aka kroeser) | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/common-capabilities) |  | |
| Compact Machines | Davenonymous, RobotGryphon | MIT | — | — | [Home](https://compactmods.dev) |  | |
| Connected Glass | SuperMartijn642 | All Rights Reserved | All Rights Reserved | — | [Modrinth](https://modrinth.com/mod/connected-glass) |  | |
| Construction Sticks | Mrbysco, ShyNieke | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/construction-sticks) |  | |
| Controlling | Jaredlll08 | MIT | MIT | MIT | [Modrinth](https://modrinth.com/mod/controlling) |  | |
| Cooking for Blockheads | BlayTheNinth | All Rights Reserved | All Rights Reserved | — | [Modrinth](https://modrinth.com/mod/cooking-for-blockheads) · [Terms](https://mods.twelveiterations.com/permissions) | Ask — see permissions page *(unverified)* | |
| CorgiLib | Corgi Taco | LGPL-3.0 | LGPL-3.0 | — | [Modrinth](https://modrinth.com/mod/corgilib) |  | |
| CosmeticArmorReworked | zlainsama | Minecraft Mod Public License 1.0.1 | — | Custom | — |  | |
| Crafting On A Stick | OfekN | GPL-3.0 ⚠️ | All Rights Reserved | — | [Modrinth](https://modrinth.com/mod/crafting-on-a-stick) |  | |
| Crafting Tweaks | BlayTheNinth | All Rights Reserved | All Rights Reserved | — | [Modrinth](https://modrinth.com/mod/crafting-tweaks) · [Terms](https://mods.twelveiterations.com/permissions) | Ask — see permissions page *(unverified)* | |
| CraftPresence | CDAGaming | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/craftpresence) · [Terms](https://gitlab.com/CDAGaming/CraftPresence/-/blob/master/LICENSE) |  | |
| Crash Assistant | KostromDan | KostromDan's Modded Minecraft Lic… | LicenseRef-LicenseRef-KostromDan-… | — | [Modrinth](https://modrinth.com/mod/crash-assistant) · [Terms](https://github.com/KostromDan/Crash-Assistant/blob/1.19-1.20.1/LICENSE.md) |  | |
| Crash Utilities | Darkere | MIT | — | — | — |  | |
| Crawl | fewizz | WTFPL | WTFPL | — | [Modrinth](https://modrinth.com/mod/crawl) |  | |
| Create | simibubi | Undeclared ⚠️ | LicenseRef-Create-Mod-License | — | [Modrinth](https://modrinth.com/mod/create) · [Terms](https://github.com/Creators-of-Create/Create/blob/HEAD/LICENSE.md) |  | |
| Create Aquatic Ambitions | Davi Oliva | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/create-aquatic-ambitions) |  | |
| Create Big Cannons | rbasamoyai | MIT ⚠️ | LicenseRef-Create-Big-Cannons-Lic… | — | [Modrinth](https://modrinth.com/mod/create-big-cannons) · [Terms](https://github.com/Cannoneers-of-Create/CreateBigCannons/blob/0b3e23456f38bac359112d82d6aad1b5430c04d1/LICENSE.md) |  | |
| Create Confectionery | Furti_Two | AFL-3.0 | MIT | — | [Modrinth](https://modrinth.com/mod/create-confectionery) |  | |
| Create Crafts & Additions | MRH0 | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/createaddition) · [Terms](https://tldrlegal.com/license/mit-license) |  | |
| Create Deco | Kayla, Talrey, Ordana, Cassian | All Rights Reserved ⚠️ | MIT | — | [Modrinth](https://modrinth.com/mod/create-deco) |  | |
| Create Nuclear | Create Nuclear | All Rights Reserved ⚠️ | MIT | — | [Modrinth](https://modrinth.com/mod/createnuclear) |  | |
| Create Ore Excavation | tom5454 | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/create-ore-excavation) |  | |
| Create Slice & Dice | possible_triangle | See linked terms | LicenseRef-Custom | — | [Modrinth](https://modrinth.com/mod/slice-and-dice) · [Terms](https://github.com/PssbleTrngle/SliceAndDice/blob/1.19.x/LICENSE.txt) |  | |
| Create: Applied Kinetics | Forsteri123 | All Rights Reserved | All Rights Reserved | — | [Modrinth](https://modrinth.com/mod/create-applied-kinetics) |  | |
| Create: Bells & Whistles | lev | GPL-3.0 | GPL-3.0 | — | [Modrinth](https://modrinth.com/mod/bellsandwhistles) |  | |
| Create: Copycats+ | Lysine, Bennyboy1695, Redcat_XVIII | All Rights Reserved | All Rights Reserved | — | [Modrinth](https://modrinth.com/mod/copycats) |  | |
| Create: Dragons Plus | DragonsPlus | LGPL-3.0 | LGPL-3.0 | LGPL-3.0+MIT | [Modrinth](https://modrinth.com/mod/create-dragons-plus) |  | |
| Create: Dreams n' Desires | LopyLuna | MIT ⚠️ | LicenseRef-MIT-Code-AND-ARR-Art | — | [Modrinth](https://modrinth.com/mod/create-dreams-and-desires) |  | |
| Create: Enchantment Industry | DragonsPlus | LGPL-3.0 | LGPL-3.0 | LGPL-3.0 | [Modrinth](https://modrinth.com/mod/create-enchantment-industry) |  | |
| Create: Escalated | rbasamoyai | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/escalated) |  | |
| Create: Extra Gauges | Liukrast, Francywott | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/extra-gauges) · [Terms](https://github.com/LIUKRAST/CreateExtraGauges/blob/master/LICENCE) |  | |
| Create: Food | average_anime | GPL-3.0 | GPL-3.0 | — | [Modrinth](https://modrinth.com/mod/create-food) |  | |
| Create: Framed | DakotaPride | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/create-framed) |  | |
| Create: Garnished | DakotaPride | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/create-garnished) |  | |
| Create: Interiors | sudolev, rdh | MIT ⚠️ | GPL-3.0 | — | [Modrinth](https://modrinth.com/mod/interiors) |  | |
| Create: Numismatics | IThundxr, Violet, Pink, Slimeist, Razziel | LGPL | LGPL-3.0 | — | [Modrinth](https://modrinth.com/mod/numismatics) |  | |
| Create: Steam 'n' Rails 1.21.1 | PoppyBlossom, Chameleon538, gblfxt | LGPL-3.0 | LGPL-3.0 | — | [Modrinth](https://modrinth.com/mod/create-steam-n-rails-1.21.1) |  | |
| Create: The Factory Must Grow | DrMangoTea, Pepa, Luna | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/create-tfmg) |  | |
| CreativeCore | CreativeMD | LGPL-3.0 | LGPL-3.0 | — | [Modrinth](https://modrinth.com/mod/creativecore) |  | |
| Creeper Overhaul | Artist/Creator - Joosh, Dev - ThatGravyBoat | All Rights Reserved | All Rights Reserved | — | [Modrinth](https://modrinth.com/mod/creeper-overhaul) |  | |
| Cucumber Library | BlakeBr0 | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/cucumber) |  | |
| Cupboard mod | Someaddon | ARR | — | — | — |  | |
| Curios API | C4 | LGPL-3.0 | LGPL-3.0 | GPL-3.0+LGPL-3.0 | [Modrinth](https://modrinth.com/mod/curios) |  | |
| Cyclops Core | rubensworks (aka kroeser) | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/cyclops-core) |  | |
| Dark Mode Everywhere | Buuz135 | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/dark-mode-everywhere) |  | |
| Deep Aether | RazorDevs | GPL-3.0 ⚠️ | LGPL-3.0 | — | [Modrinth](https://modrinth.com/mod/deep-aether) |  | |
| Deeper and Darker | Kyanite Team | GPL-3.0 | AGPL-3.0 | — | [Modrinth](https://modrinth.com/mod/deeperdarker) |  | |
| Deimos | Mars | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/deimos) |  | |
| Deployer | Liukrast, SWZO | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/deployer) |  | |
| Design n' Decor | LopyLuna, DrMangoTea | MIT ⚠️ | LicenseRef-MIT-Code-AND-ARR-Art | — | [Modrinth](https://modrinth.com/mod/create-design-n-decor) |  | |
| Diagonal Fences | Fuzs, XFactHD | MPL-2.0 | MPL-2.0 | All Rights Reserved+LGPL-3.0 | [Modrinth](https://modrinth.com/mod/diagonal-fences) |  | |
| Diagonal Walls | Fuzs, XFactHD | MPL-2.0 | MPL-2.0 | All Rights Reserved+LGPL-3.0 | [Modrinth](https://modrinth.com/mod/diagonal-walls) |  | |
| Diagonal Windows | Fuzs, XFactHD | MPL-2.0 | MPL-2.0 | All Rights Reserved+LGPL-3.0 | [Modrinth](https://modrinth.com/mod/diagonal-windows) |  | |
| DimStorage | Edivad99 | AGPL-3.0 | AGPL-3.0 | — | [Modrinth](https://modrinth.com/mod/dimstorage) |  | |
| Dis-Enchanting Table | Lupin, Jason13 | Unlicense ⚠️ | All Rights Reserved | — | [Modrinth](https://modrinth.com/mod/dis-enchanting-table) |  | |
| Domum Ornamentum | LDTTeam, OrionDevelopment | GPL-3.0 | — | — | — |  | |
| Draconic Evolution | brandon3055 | CoFH \ | LicenseRef-CoFH-Dont-Be-a-Jerk-Li… | — | [Modrinth](https://modrinth.com/mod/draconic-evolution) · [Terms](https://github.com/Draconic-Inc/Draconic-Evolution/blob/master/LICENSE.md) |  | |
| Draconic Evolution Render Patcher | Yrley | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/draconic-evolution-render-patcher) |  | |
| Drippy Early Loading Module |  | Undeclared | LicenseRef-DSMSLv3 | — | [Modrinth](https://modrinth.com/mod/drippy-early-loading-module) · [Terms](https://github.com/Keksuccino/Drippy-Loading-Screen/blob/main/LICENSE.md) |  | |
| Drippy Loading Screen | Keksuccino | DSMSLv3 (DON'T SNATCH MA STUFF LI… | LicenseRef-DSMSLv3 | — | [Modrinth](https://modrinth.com/mod/drippy-loading-screen) · [Terms](https://github.com/Keksuccino/Drippy-Loading-Screen/blob/main/LICENSE.md) |  | |
| Dungeon Crawl | xiroc | GPL-3.0 | GPL-3.0 | — | [Modrinth](https://modrinth.com/mod/dungeoncrawl) |  | |
| Dungeons and Taverns |  | All Rights Reserved | All Rights Reserved | — | [Modrinth](https://modrinth.com/mod/dungeons-and-taverns) |  | |
| Durability Tooltip | SuperMartijn642 | All Rights Reserved | All Rights Reserved | — | [Modrinth](https://modrinth.com/mod/durability-tooltip) |  | |
| Dyenamics | LobsterJonn, Hekera, Reda, Cait | All Rights Reserved | — | — | — |  | |
| Dyenamics and Friends | LobsterJonn | All Rights Reserved | — | — | — |  | |
| Dyson Cube Project | Buuz135 | MIT | — | — | — |  | |
| Easy Anvils | Fuzs | MPL-2.0 | MPL-2.0 | All Rights Reserved+LGPL-3.0 | [Modrinth](https://modrinth.com/mod/easy-anvils) |  | |
| Easy Villagers | Max Henkel | All Rights Reserved | All Rights Reserved | — | [Modrinth](https://modrinth.com/mod/easy-villagers) |  | |
| EdivadLib | Edivad99 | AGPL-3.0 ⚠️ | LGPL-3.0 | — | [Modrinth](https://modrinth.com/mod/edivadlib) |  | |
| Electrodynamics | aurilisdev, skip999 | AURILISDEV LICENSE | LicenseRef-AURILISDEV-LICENSE-1.0… | — | [Modrinth](https://modrinth.com/mod/electrodynamics) · [Terms](https://github.com/aurilisdev/Electrodynamics/blob/1.20/LICENSE.txt) |  | |
| ElevatorMod | VsnGamer | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/elevatormod) |  | |
| EnchantmentDescriptions | Darkhax | LGPL-2.1 | LGPL-2.1 | LGPL-3.0 | [Modrinth](https://modrinth.com/mod/enchantment-descriptions) |  | |
| Ender IO | CrazyPants, tterrag, HenryLoenwind, MatthiasM, Cyanide… | CC0-1.0 | Unlicense | — | [Modrinth](https://modrinth.com/mod/enderio) |  | |
| EnderDrives | STS15 | MIT | — | MIT | — |  | |
| Enderman Overhaul | Alex Nijjar, Joosh | ARR ⚠️ | All Rights Reserved | — | [Modrinth](https://modrinth.com/mod/enderman-overhaul) |  | |
| EnderStorage | ChickenBones, covers1624 | MIT | MIT | MIT | [Modrinth](https://modrinth.com/mod/ender-storage) |  | |
| Energy Meter | Almost Reliable | All Rights Reserved | All Rights Reserved | — | [Modrinth](https://modrinth.com/mod/energymeter) |  | |
| Entangled | SuperMartijn642 | All Rights Reserved | All Rights Reserved | — | [Modrinth](https://modrinth.com/mod/entangled) |  | |
| EntityCulling | tr7zw | tr7zw Protective License | LicenseRef-tr7zw-Protective-Licen… | MIT | [Modrinth](https://modrinth.com/mod/entityculling) · [Terms](https://github.com/tr7zw/EntityCulling/blob/1.18/LICENSE-EntityCulling) | Yes — non-commercial only | |
| Eternal Starlight | LeoLezury | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/eternal-starlight) |  | |
| Euphoria Patcher | SpacEagle17 | MPL-2.0 | MPL-2.0 | Apache-2.0+BSD | [Modrinth](https://modrinth.com/mod/euphoria-patches) |  | |
| Everything Bugs | Forge Everything Team | All Rights Reserved | — | — | — |  | |
| Everything is Copper | LobsterJonn | All Rights Reserved | — | — | — |  | |
| Everything Ores |  | MIT | — | — | — |  | |
| EvilCraft / EvilCraft-Compat | rubensworks (aka kroeser) | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/evilcraft) |  | |
| Explore Ruins Aether | NoCube | Undeclared ⚠️ | All Rights Reserved | — | [Modrinth](https://modrinth.com/mod/explore-ruins-aether) |  | |
| Explorer's Compass | ChaosTheDude | CC BY-NC-SA | CC BY-NC-SA | — | [Modrinth](https://modrinth.com/mod/explorers-compass) |  | |
| Explorify | bebebea_loste | ARR ⚠️ | All Rights Reserved | — | [Modrinth](https://modrinth.com/mod/explorify) |  | |
| Extended Industrialization | Swedz | MIT | MIT | MIT | [Modrinth](https://modrinth.com/mod/extended-industrialization) |  | |
| ExtendedAE | GlodBlock | LGPL-3.0 | LGPL-3.0 | — | [Modrinth](https://modrinth.com/mod/extended-ae) · [Terms](https://github.com/GlodBlock/ExtendedAE?tab=LGPL-3.0-1-ov-file) |  | |
| Extra Disks | MelanX | Apache-2.0 | MIT | — | [Modrinth](https://modrinth.com/mod/extra-disks) |  | |
| ExtraSpecialCore | Extra_Special_K, TWGMike, Manialate | MIT | — | — | [Home](https://unbound.creatopia.uk) |  | |
| ExtraStorage | Edivad99 | AGPL-3.0 | AGPL-3.0 | — | [Modrinth](https://modrinth.com/mod/extrastorage) |  | |
| Extreme Reactors | ZeroNoRyouki | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/extreme-reactors) |  | |
| Extreme Sound Muffler | LeoBeliik | LGPL | LGPL-3.0 | — | [Modrinth](https://modrinth.com/mod/extreme_sound_muffler) |  | |
| Factory Blocks | slaincow | MIT | — | — | — |  | |
| FancyMenu | Keksuccino | DSMSLv3 (DON'T SNATCH MA STUFF LI… | LicenseRef-DSMSLv3 | — | [Modrinth](https://modrinth.com/mod/fancymenu) · [Terms](https://github.com/Keksuccino/FancyMenu/blob/master/LICENSE.md) |  | |
| Farmer's Delight | vectorwing | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/farmers-delight) |  | |
| Fast Workbench | Shadows_of_Fire | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/fastworkbench) |  | |
| FastFurnace | Shadows_of_Fire | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/fastfurnace) |  | |
| Ferrite Core | malte0811 | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/ferrite-core) |  | |
| FlickerFix |  | All Rights Reserved ⚠️ | MIT | — | [Modrinth](https://modrinth.com/mod/flickerfix) |  | |
| Flux Networks | Sonar Sonic, BloCamLimb | MIT | — | — | [Home](https://www.curseforge.com/minecraft/mc-mods/flux-networks) |  | |
| Forbidden Arcanus |  | All Rights Reserved | All Rights Reserved | — | [Modrinth](https://modrinth.com/mod/forbidden-arcanus) |  | |
| Forgified Fabric API / Forgified Fabric API (dummy) | Sinytra, FabricMC | Apache-2.0 | Apache-2.0 | — | [Modrinth](https://modrinth.com/mod/forgified-fabric-api) · [Terms](https://github.com/Sinytra/ForgifiedFabricAPI/blob/1.20.1/LICENSE) |  | |
| Formations | SuperMartijn642 | All Rights Reserved | All Rights Reserved | — | [Modrinth](https://modrinth.com/mod/formations) |  | |
| Formations Nether | SuperMartijn642 | All Rights Reserved | All Rights Reserved | — | [Modrinth](https://modrinth.com/mod/formations-nether) |  | |
| Formations Overworld | SuperMartijn642 | All Rights Reserved | All Rights Reserved | — | [Modrinth](https://modrinth.com/mod/formations-overworld) |  | |
| FramedBlocks | XFactHD | LGPL-3.0 | LGPL-3.0 | — | [Modrinth](https://modrinth.com/mod/framedblocks) |  | |
| Framework | MrCrayfish | LGPL-2.1 | — | LGPL-3.0 | [Home](https://mrcrayfish.com/mods?id=framework) |  | |
| FTB Chunks | FTB Team | All Rights Reserved | — | — | — |  | |
| FTB Essentials | FTB Team | All Rights Reserved | — | — | — |  | |
| FTB Filter System | FTB Team | All Rights Reserved | — | — | [Home](https://www.curseforge.com/minecraft/mc-mods/ftb-filter-system) |  | |
| FTB Jei Extras | FTB Team | All Rights Reserved | — | — | — |  | |
| FTB Library | FTB Team | All Rights Reserved | — | — | — |  | |
| FTB Quests | FTB Team | All Rights Reserved | — | — | — |  | |
| FTB Quests Lang Splitter | Uncandango | MIT | — | — | — |  | |
| FTB Ranks | FTB Team | All Rights Reserved | — | — | — |  | |
| FTB Teams | FTB Team | All Rights Reserved | — | — | — |  | |
| FTB Ultimine | FTB Team | All Rights Reserved | — | — | — |  | |
| Fusion | SuperMartijn642 | All Rights Reserved | All Rights Reserved | — | [Modrinth](https://modrinth.com/mod/fusion-connected-textures) |  | |
| Gateways To Eternity | Shadows_of_Fire | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/gateways-to-eternity) |  | |
| GeckoLib 4 | Gecko, Eliot, AzureDoom, DerToaster, Tslat, Witixin | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/geckolib) |  | |
| Generator Galore | LobsterJonn | All Rights Reserved | — | — | — |  | |
| Get It Together, Drops! | bl4ckscor3 | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/get-it-together-drops) |  | |
| Glassential-renewed | Big_Energy | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/glassential-renewed) |  | |
| GlitchCore | Adubbz | All Rights Reserved | All Rights Reserved | — | [Modrinth](https://modrinth.com/mod/glitchcore) |  | |
| Glodium | GlodBlock | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/glodium) |  | |
| Gravestone Mod | Max Henkel | All Rights Reserved | All Rights Reserved | — | [Modrinth](https://modrinth.com/mod/gravestone-mod) |  | |
| Gravitational Modulating Additional Unit | gisellevonbingen | MIT | — | — | [Home](https://www.curseforge.com/minecraft/mc-mods/gravitational-modulating-additional-unit) |  | |
| GuideME | shartte | Undeclared ⚠️ | LicenseRef-Multiple-OSS-Licenses | Apache-2.0 | [Modrinth](https://modrinth.com/mod/guideme) · [Terms](https://github.com/AppliedEnergistics/GuideME/blob/main/LICENSE.MD) |  | |
| Handcrafted | Alex Nijjar, Kekie6 | Terrarium Licence | LicenseRef-Terrarium-Licence | — | [Modrinth](https://modrinth.com/mod/handcrafted) · [Terms](https://github.com/terrarium-earth/Handcrafted/blob/1.19.2/LICENSE) |  | |
| Hellish Trials | Aureljz, Kaapre | ARR ⚠️ | All Rights Reserved | — | [Modrinth](https://modrinth.com/mod/hellish-trials) |  | |
| Hostile Neural Networks | Shadows_of_Fire | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/hostile-neural-networks) |  | |
| Icarus | Cammie, Up | See linked terms | LicenseRef-Custom | MIT | [Modrinth](https://modrinth.com/mod/icarus) · [Terms](https://github.com/Up-Mods/Icarus/blob/HEAD/LICENSE.md) |  | |
| Ice And Fire Community Edition | IAFEnvoy, xiaowu, uoay | LGPL-3.0 | LGPL-3.0 | — | [Modrinth](https://modrinth.com/mod/iceandfire-ce) |  | |
| Ice and Fire: Spellbooks | Ace The Eldritch King | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/ice-and-fire-spellbooks) |  | |
| Iceberg | Grend | CC BY-NC-ND | CC BY-NC-ND | — | [Modrinth](https://modrinth.com/mod/iceberg) |  | |
| ImmediatelyFast | RK_01 | LGPL-3.0 | LGPL-3.0 | LGPL-3.0 | [Modrinth](https://modrinth.com/mod/immediatelyfast) |  | |
| Immersive Energistics | Technici4n | LGPL-3.0 | LGPL-3.0 | — | [Modrinth](https://modrinth.com/mod/immersive-energistics) |  | |
| Immersive Engineering | BluSunrize and Damien A.W. Hazard | Blu's License of Common Sense | LicenseRef-Custom | — | [Modrinth](https://modrinth.com/mod/immersiveengineering) · [Terms](https://github.com/BluSunrize/ImmersiveEngineering/blob/1.16.5/LICENSE) |  | |
| InControl | McJty | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/in-control) |  | |
| Industrial Foregoing | Buuz135 | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/industrial-foregoing) |  | |
| Industrial Foregoing Souls | Buuz135, Rid | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/industrial-foregoing-souls) |  | |
| Industrialization Overdrive | White_Phantom | MIT | — | — | — |  | |
| Integrated API | CraisinLord | All Rights Reserved | All Rights Reserved | — | [Modrinth](https://modrinth.com/mod/integrated-api) |  | |
| Integrated Cataclysm | CraisinLord | All Rights Reserved | All Rights Reserved | — | [Modrinth](https://modrinth.com/mod/integrated-catalcysm) |  | |
| Integrated Dungeons and Structures | CraisinLord | All Rights Reserved | All Rights Reserved | — | [Modrinth](https://modrinth.com/mod/idas) |  | |
| IntegratedCrafting | rubensworks (aka kroeser) | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/integrated-crafting) |  | |
| IntegratedDynamics / IntegratedDynamics-Compat | rubensworks (aka kroeser) | MIT | MIT | Apache-2.0+BSD | [Modrinth](https://modrinth.com/mod/integrated-dynamics) |  | |
| IntegratedScripting | rubensworks (aka kroeser) | MIT | MIT | Custom | [Modrinth](https://modrinth.com/mod/integrated-scripting) |  | |
| IntegratedTerminals / IntegratedTerminals-Compat | rubensworks (aka kroeser) | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/integrated-terminals) |  | |
| IntegratedTunnels / IntegratedTunnels-Compat | rubensworks (aka kroeser) | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/integrated-tunnels) |  | |
| Interdimensional Wireless Transmitter | Ultramega | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/interdimensional-wireless-transmitter) |  | |
| Inventory Tweaks Refoxed | LobsterJonn (Current maintainer) | Apache-2.0 | Apache-2.0 | — | [Modrinth](https://modrinth.com/mod/inventory-tweaks-refoxed) |  | |
| Iris | coderbot, IMS212 | LGPL-3.0 | LGPL-3.0 | — | [Modrinth](https://modrinth.com/mod/iris) |  | |
| Iron Furnaces | Qelifern (pizzaatime), XenoMustache | Apache-2.0 | Apache-2.0 | — | [Modrinth](https://modrinth.com/mod/iron-furnaces) |  | |
| Iron Jetpacks | BlakeBr0 | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/iron-jetpacks) |  | |
| Iron's Gems 'n Jewelry | Iron431 | All Rights Reserved | — | — | — |  | |
| Iron's Lib |  | All Rights Reserved | All Rights Reserved | — | [Modrinth](https://modrinth.com/mod/irons-lib) |  | |
| Iron's Spells 'n Spellbooks | Iron431, Lab3 | All Rights Reserved | All Rights Reserved | — | [Modrinth](https://modrinth.com/mod/irons-spells-n-spellbooks) · [Terms](https://github.com/iron431/Irons-Spells-n-Spellbooks#readme) |  | |
| Item Borders | Grend | CC BY-NC-ND | CC BY-NC-ND | — | [Modrinth](https://modrinth.com/mod/item-borders) |  | |
| Jade | Snownee | CC BY-NC-SA | CC BY-NC-SA | — | [Modrinth](https://modrinth.com/mod/jade) |  | |
| Jupiter | IAFEnvoy | LGPL-3.0 | LGPL-3.0 | — | [Modrinth](https://modrinth.com/mod/jupiter) |  | |
| Just Enough Archaeology | LobsterJonn | All Rights Reserved | All Rights Reserved | — | [Modrinth](https://modrinth.com/mod/just-enough-archaeology) |  | |
| Just Enough Breeding | Christofmeg | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/justenoughbreeding) |  | |
| Just Enough Effects Descriptions | MehVahdJukaar | GPL-3.0 ⚠️ | All Rights Reserved | — | [Modrinth](https://modrinth.com/mod/just-enough-effect-descriptions-jeed) |  | |
| Just Enough Items | mezz | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/jei) |  | |
| Just Enough Professions (JEP) | Mrbysco, ShyNieke | MIT | MIT | MIT | [Modrinth](https://modrinth.com/mod/just-enough-professions-jep) |  | |
| Just Enough Resources | way2muchnoise | 'Don't Be a Jerk' non-commercial… | LicenseRef-Dont-Be-a-Jerk | — | [Modrinth](https://modrinth.com/mod/just-enough-resources-jer) · [Terms](https://github.com/way2muchnoise/JustEnoughResources/blob/master/LICENSE.md) |  | |
| Just Zoom | Keksuccino | DSMSLv3 (DON'T SNATCH MA STUFF LI… | LicenseRef-DSMSLv2 | — | [Modrinth](https://modrinth.com/mod/just-zoom) · [Terms](https://github.com/Keksuccino/JustZoom/blob/main/LICENSE.md) |  | |
| KeyBind Bundles | Matyrobbrt | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/keybind-bundles) |  | |
| KeybindsPurger | ZedDevStuff | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/keybindspurger) · [Terms](https://github.com/ZedDevStuff/KeybindsPurger/blob/1.20.1/LICENSE) |  | |
| Konkrete | Keksuccino | Apache-2.0 | Apache-2.0 | — | [Modrinth](https://modrinth.com/mod/konkrete) |  | |
| Kotlin for Forge |  | Undeclared | LGPL-2.1 | — | [Modrinth](https://modrinth.com/mod/kotlin-for-forge) |  | |
| KubeJS | latvian.dev | LGPL-3.0 | LGPL-3.0 | — | [Modrinth](https://modrinth.com/mod/kubejs) |  | |
| KubeJS Additions | ILIKEPIEFOO2 | All Rights Reserved ⚠️ | MIT | — | [Modrinth](https://modrinth.com/mod/kubejs-additions) |  | |
| KubeJS Create | latvian.dev | MIT ⚠️ | LGPL-3.0 | — | [Modrinth](https://modrinth.com/mod/kubejs-create) |  | |
| KubeJS Tweaks | Uncandango | MIT | — | — | — |  | |
| L_Ender's Cataclysm 1.21.1 | L_Ender | LGPL-3.0 ⚠️ | CC BY-NC-ND | — | [Modrinth](https://modrinth.com/mod/l_enders-cataclysm) |  | |
| Laser Bridges & Doors | Mars | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/laser-bridges-and-doors) |  | |
| LaserIO | Direwolf20, ErrorMikey | MIT | — | — | [Home](https://github.com/Direwolf20-MC/LaserIO) |  | |
| Legendary Tooltips | Grend | CC BY-NC-ND | CC BY-NC-ND | — | [Modrinth](https://modrinth.com/mod/legendary-tooltips) |  | |
| legendary_monsters | ${mod_authors} | Undeclared ⚠️ | All Rights Reserved | — | [Modrinth](https://modrinth.com/mod/legendary-monsters) |  | |
| Let Me Despawn | frikinjay | LGPL-3.0 | LGPL-3.0 | — | [Modrinth](https://modrinth.com/mod/lmd) |  | |
| lionfishapi | L_Ender | LGPL | LGPL-3.0 | — | [Modrinth](https://modrinth.com/mod/lionfish-api) |  | |
| Lithostitched | Apollo | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/lithostitched) |  | |
| Little Big Redstone | Swedz | MIT | MIT | MIT | [Modrinth](https://modrinth.com/mod/little-big-redstone) |  | |
| Living Things | Buecher_wurm | CC BY-NC-ND | CC BY-NC-ND | CC BY-NC-ND | [Modrinth](https://modrinth.com/mod/living-things) |  | |
| Load My F***ing Tags | Blodhgarm | CC0-1.0 | CC0-1.0 | — | [Modrinth](https://modrinth.com/mod/lmft) |  | |
| LootJS | AlmostReliable | LGPL-3.0 | LGPL-3.0 | — | [Modrinth](https://modrinth.com/mod/lootjs) |  | |
| Lootr | Noobanidus | See linked terms ⚠️ | MIT | — | [Modrinth](https://modrinth.com/mod/lootr) |  | |
| Luminax | Satherov | LGPL-3.0 | LGPL-3.0 | — | [Modrinth](https://modrinth.com/mod/luminax) |  | |
| Macaw's Bridges | Sketch Macaw & Peachy Macaw | All Rights Reserved | All Rights Reserved | — | [Modrinth](https://modrinth.com/mod/macaws-bridges) |  | |
| Macaw's Doors | Sketch Macaw & Sketch Peachy | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/macaws-doors) |  | |
| Macaw's Fences and Walls | Sketch Macaw & Peachy Macaw | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/macaws-fences-and-walls) |  | |
| Macaw's Furniture | Sketch Macaw | All Rights Reserved | All Rights Reserved | — | [Modrinth](https://modrinth.com/mod/macaws-furniture) |  | |
| Macaw's Holidays | Sketch Macaw & Peachy Macaw | All Rights Reserved | All Rights Reserved | — | [Modrinth](https://modrinth.com/mod/macaws-holidays) |  | |
| Macaw's Lights and Lamps | Sketch Macaw & Peachy Macaw | All Rights Reserved | All Rights Reserved | — | [Modrinth](https://modrinth.com/mod/macaws-lights-and-lamps) |  | |
| Macaw's Oh The Biomes We've Gone | Samlegamer | All Rights Reserved | All Rights Reserved | — | [Modrinth](https://modrinth.com/mod/macaws-byg-bwg) | Yes — CC0 *(unverified)* | |
| Macaw's Paintings | Art made by Peachy, coded by Sketch Macaw | All Rights Reserved | All Rights Reserved | — | [Modrinth](https://modrinth.com/mod/macaws-paintings) |  | |
| Macaw's Paths and Pavings | Sketch Macaw & Peachy Macaw | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/macaws-paths-and-pavings) |  | |
| Macaw's Regions Unexplored | Samlegamer | All Rights Reserved | All Rights Reserved | — | [Modrinth](https://modrinth.com/mod/macaws-regions-unexplored) | Yes — CC0 *(unverified)* | |
| Macaw's Roofs | Sketch Macaw & Sketch Peachy | All Rights Reserved | All Rights Reserved | — | [Modrinth](https://modrinth.com/mod/macaws-roofs) |  | |
| Macaw's Stairs and Balconies | Sketch Macaw & Sketch Peachy | All Rights Reserved | All Rights Reserved | — | [Modrinth](https://modrinth.com/mod/macaws-stairs) |  | |
| Macaw's Trapdoors | Sketch Macaw & Peachy Macaw | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/macaws-trapdoors) |  | |
| Macaw's Windows | Sketch Macaw & Peachy Macaw | All Rights Reserved | All Rights Reserved | — | [Modrinth](https://modrinth.com/mod/macaws-windows) |  | |
| Magnum Torch | Fuzs | MPL-2.0 | MPL-2.0 | All Rights Reserved+LGPL-3.0 | [Modrinth](https://modrinth.com/mod/magnum-torch) |  | |
| Mahou Tsukai | stepsword | All Rights Reserved | All Rights Reserved | — | [Modrinth](https://modrinth.com/mod/mahou-tsukai) |  | |
| McJtyLib | McJty | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/mcjtylib) |  | |
| ME Requester | Almost Reliable | LGPL-3.0 | LGPL-3.0 | — | [Modrinth](https://modrinth.com/mod/merequester) |  | |
| MEGA Cells | 90 | LGPL-3.0 | LGPL-3.0 | LGPL-3.0 | [Modrinth](https://modrinth.com/mod/mega) |  | |
| Mekanism | Aidancbrady, Thommy101, Thiakil, pupnewfster, dizzyd | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/mekanism) |  | |
| Mekanism: Additions | Aidancbrady, Thommy101, Thiakil, pupnewfster, dizzyd | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/mekanism-additions) |  | |
| Mekanism: Generators | Aidancbrady, Thommy101, Thiakil, pupnewfster, dizzyd | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/mekanism-generators) |  | |
| Mekanism: MoreMachine | Lost Myself | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/mekanismmoremachine) |  | |
| Mekanism: Tools | Aidancbrady, Thommy101, Thiakil, pupnewfster, dizzyd | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/mekanism-tools) |  | |
| Mekanistic Routers | Matyrobbrt | MIT | — | — | — |  | |
| Melody | Keksuccino | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/melody) |  | |
| memorysettings mod | Someaddon | ARR | — | — | — |  | |
| MES - Moog's End Structures |  | LGPL-3.0 | LGPL-3.0 | — | [Modrinth](https://modrinth.com/mod/mes-moogs-end-structures) |  | |
| MineColonies | LDT Team | GPL-3.0 | — | — | [Home](https://minecolonies.com) |  | |
| Mining Gadgets | Direwolf20, ErrorMikey | MIT | — | — | [Home](https://github.com/Direwolf20-MC/MiningGadgets/) |  | |
| MmmMmmMmmMmm | Mehvahdjukaar, Bonusboni, Gooigipunch, Plantkillable | Supplementaries Team License v.1.5 ⚠️ | CC0-1.0 | — | [Modrinth](https://modrinth.com/mod/mmmmmmmmmmmm) | Yes — manifest only *(unverified)* | |
| MNS - Moog's Nether Structures |  | LGPL-3.0 | LGPL-3.0 | — | [Modrinth](https://modrinth.com/mod/mns-moogs-nether-structures) |  | |
| Model Gap Fix | MehVahdJukaar | GPL-3.0 | GPL-3.0 | — | [Modrinth](https://modrinth.com/mod/modelfix) |  | |
| Modern Dynamics | Technici4n | LGPL-3.0 | LGPL-3.0 | — | [Modrinth](https://modrinth.com/mod/modern-dynamics) |  | |
| Modern Industrialization | Azerococo,Technici4n | MIT | MIT | MIT | [Modrinth](https://modrinth.com/mod/modern-industrialization) |  | |
| ModernFix | embeddedt | LGPL-3.0 | LGPL-3.0 | — | [Modrinth](https://modrinth.com/mod/modernfix) |  | |
| Modonomicon | Kli Kli | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/modonomicon) · [Terms](https://github.com/klikli-dev/modonomicon#licensing) |  | |
| Modular Force Fields | aurilisdev | All Rights Reserved ⚠️ | LicenseRef-AURILISDEV-LICENSE-1.0… | — | [Modrinth](https://modrinth.com/mod/modular-force-field-systems) · [Terms](https://github.com/aurilisdev/Electrodynamics/blob/1.20/LICENSE.txt) |  | |
| Modular Routers | Des Herriott | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/modular-routers) |  | |
| MonoLib | Lupin, Jason13 | Unlicense | Unlicense | Custom | [Modrinth](https://modrinth.com/mod/monolib) · [Terms](https://unlicense.org/) |  | |
| Moog's Structure Lib | FinnDog | See linked terms ⚠️ | LGPL-3.0 | — | [Modrinth](https://modrinth.com/mod/moogs-structure-lib) |  | |
| Moonlight Lib | MehVahdJukaar | Supplementaries Team License v.1.5 ⚠️ | LGPL | — | [Modrinth](https://modrinth.com/mod/moonlight) · [Terms](https://github.com/MehVahdJukaar/Moonlight/blob/1.20/license.md) | Yes — manifest only *(unverified)* | |
| More Dragon Eggs | Darkere | MIT | — | — | — |  | |
| More Industrial Foregoing Addons | Christofmeg | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/mifa) |  | |
| More Overlays Updated | feldim2425, RiDGo8 | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/more-overlays-updated) · [Terms](https://raw.githubusercontent.com/r8420/MoreOverlays-updated/master-1.20/LICENSE.md) |  | |
| More Red | Commoble | MIT | — | — | [Home](https://www.curseforge.com/minecraft/mc-mods/more-red) |  | |
| More Red x CC:Tweaked Compat | YuRaNnNzZZ | MIT | — | — | [Home](https://www.curseforge.com/minecraft/mc-mods/more-red-x-cc-tweaked-compat) |  | |
| Mouse Tweaks | Ivan Molodetskikh (YaLTeR) | BSD | BSD | — | [Modrinth](https://modrinth.com/mod/mouse-tweaks) |  | |
| MrCrayfish's Furniture Mod: Refurbished | MrCrayfish | MIT | — | — | [Home](https://mrcrayfish.com/mods/furniture_refurbished) |  | |
| MSS - Moog's Soaring Structures |  | LGPL-3.0 ⚠️ | GPL-3.0 | — | [Modrinth](https://modrinth.com/mod/mss-moogs-soaring-structures) |  | |
| Multi-Piston | Let's Dev Together Team | GPL-3.0 | — | — | — |  | |
| Mutant Monsters | shcott21, Chumbanotz, Fuzs, tdstress | AGPL-3.0 | AGPL-3.0 | AGPL-3.0+All Rights Reserved | [Modrinth](https://modrinth.com/mod/mutant-monsters) |  | |
| MVS - Moog's Voyager Structures |  | LGPL-3.0 ⚠️ | MIT | — | [Modrinth](https://modrinth.com/mod/moogs-voyager-structures) |  | |
| Mystcraft: Reborn | studioREWIRED | CC BY-SA | CC BY-SA | — | [Modrinth](https://modrinth.com/mod/mystcraft-reborn) |  | |
| Mystical Agradditions | BlakeBr0 | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/mystical-agradditions) |  | |
| Mystical Agriculture | BlakeBr0 | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/mystical-agriculture) |  | |
| Mystical Customization | BlakeBr0 | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/mystical-customization) |  | |
| Nature's Compass | ChaosTheDude | CC BY-NC-SA | CC BY-NC-SA | — | [Modrinth](https://modrinth.com/mod/natures-compass) |  | |
| NaturesAura | Ellpeck | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/natures-aura) |  | |
| NetherPortalFix | BlayTheNinth | All Rights Reserved | All Rights Reserved | All Rights Reserved | [Modrinth](https://modrinth.com/mod/netherportalfix) · [Terms](https://mods.twelveiterations.com/permissions) | Ask — see permissions page | |
| No Chat Reports | Aizistral | WTFPL | WTFPL | Custom | [Modrinth](https://modrinth.com/mod/no-chat-reports) |  | |
| NotEnoughAnimations | tr7zw | tr7zw Protective License | LicenseRef-tr7zw-Protective-Licen… | MIT | [Modrinth](https://modrinth.com/mod/not-enough-animations) · [Terms](https://github.com/tr7zw/NotEnoughAnimations/blob/main/LICENSE) | Yes — non-commercial only | |
| Nuclear Science | aurilisdev, skip999 | AURILISDEV LICENSE | LicenseRef-AURILISDEV-LICENSE-1.0… | — | [Modrinth](https://modrinth.com/mod/nuclear-science) · [Terms](https://github.com/aurilisdev/Electrodynamics/blob/1.20/LICENSE.txt) |  | |
| Nullscape | Stardust Labs | Stardust Labs License | LicenseRef-Stardust-Labs-License | Custom | [Modrinth](https://modrinth.com/mod/nullscape) · [Terms](https://github.com/Stardust-Labs-MC/license/blob/main/license.txt) | Yes — with attribution | |
| Observable | tasgon | MPL-2.0 | MPL-2.0 | — | [Modrinth](https://modrinth.com/mod/observable) |  | |
| Occultism | Kli Kli | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/occultism) · [Terms](https://github.com/klikli-dev/occultism#licensing) |  | |
| Occultism KubeJS | Kli Kli | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/occultism-kubejs) · [Terms](https://github.com/klikli-dev/occultism-kubejs/blob/version/1.19/LICENSE) |  | |
| OctoLib | OctoStudios | All Rights Reserved | All Rights Reserved | — | [Modrinth](https://modrinth.com/mod/shatterbyte-lib) |  | |
| Oh The Biomes We've Gone | Joseph T. McQuigg (JT122406), AOCAWOL, YaBoiChips, Cor… | All Rights Reserved | All Rights Reserved | — | [Modrinth](https://modrinth.com/mod/oh-the-biomes-weve-gone) |  | |
| Oh The Trees You'll Grow | Corgi Taco | LGPL-3.0 | LGPL-3.0 | — | [Modrinth](https://modrinth.com/mod/oh-the-trees-youll-grow) |  | |
| Open Parties and Claims | Xaero96 and other contributors | LGPL-3.0 | LGPL-3.0 | LGPL-3.0 | [Modrinth](https://modrinth.com/mod/open-parties-and-claims) |  | |
| Oritech | Me! - Rearth | CC0-1.0 ⚠️ | CC BY | — | [Modrinth](https://modrinth.com/mod/oritech) · [Terms](https://github.com/Rearth/Oritech?tab=CC0-1.0-1-ov-file) |  | |
| oωo | glisco, Blodhgarm, BasiqueEvangelist, Noaaan | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/owo-lib) |  | |
| PacketFixer | TonimatasDEV | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/packet-fixer) |  | |
| Pam's HarvestCraft - Crops | Pamela Collins, ie MatrexsVigil, PamHarvestCraft | All Rights Reserved | All Rights Reserved | — | [Modrinth](https://modrinth.com/mod/pams-harvestcraft-2-crops) |  | |
| Pam's HarvestCraft - Food Core | Pamela Collins, ie MatrexsVigil, PamHarvestCraft | All Rights Reserved | All Rights Reserved | — | [Modrinth](https://modrinth.com/mod/pams-harvestcraft-2-food-core) |  | |
| Pam's HarvestCraft - Food Extended | Pamela Collins, ie MatrexsVigil, PamHarvestCraft | All Rights Reserved | All Rights Reserved | — | [Modrinth](https://modrinth.com/mod/pams-harvestcraft-2-food-extended) |  | |
| Pam's HarvestCraft - Trees | Pamela Collins, ie MatrexsVigil, PamHarvestCraft | All Rights Reserved | All Rights Reserved | — | [Modrinth](https://modrinth.com/mod/pams-harvestcraft-2-trees) |  | |
| Patchouli | Vazkii | CC BY-NC-SA | CC BY-NC-SA | — | [Modrinth](https://modrinth.com/mod/patchouli) |  | |
| Paxi | YUNGNICKYOUNG | LGPL-3.0 | LGPL-3.0 | — | [Modrinth](https://modrinth.com/mod/paxi) |  | |
| Placebo | Shadows_of_Fire | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/placebo) |  | |
| Player Animator | KosmX | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/playeranimator) |  | |
| PneumaticCraft: Repressurized | desht, MineMaarten | GPL-3.0 ⚠️ | LGPL-2.1 | — | [Modrinth](https://modrinth.com/mod/pneumaticcraft-repressurized) |  | |
| PonderJS | AlmostReliable | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/ponder) |  | |
| Potentials | Fej1Fun | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/potentials) |  | |
| Powah | owmii,Technici4n,shartte | LGPL-3.0 | LGPL-3.0 | LGPL-3.0 | [Modrinth](https://modrinth.com/mod/powah) |  | |
| PrickleMC | Darkhax | LGPL-2.1 | LGPL-2.1 | LGPL-3.0 | [Modrinth](https://modrinth.com/mod/prickle) |  | |
| Prism | Grend | CC BY-NC-ND | CC BY-NC-ND | — | [Modrinth](https://modrinth.com/mod/prism-lib) |  | |
| ProbeJS | Prunoideae | GPL-3.0 ⚠️ | LGPL-2.1 | — | [Modrinth](https://modrinth.com/mod/probejs) |  | |
| Productive Bees | LobsterJonn | All Rights Reserved | — | — | — |  | |
| Productive Farming | LobsterJonn | All Rights Reserved | — | — | — |  | |
| Productive Metalworks | LobsterJonn | All Rights Reserved | — | — | — |  | |
| Productive Trees | LobsterJonn | All Rights Reserved | — | — | — |  | |
| ProjectE | SinKillerJ, MaPePeR, williewillus, Lilylicious, pupnew… | MIT | — | — | [Home](https://github.com/sinkillerj/ProjectE) |  | |
| Protect Your Moa | bconlon, Oz Payn | LGPL-3.0 ⚠️ | LicenseRef-Custom | — | [Modrinth](https://modrinth.com/mod/aether-protect-your-moa) · [Terms](https://github.com/The-Aether-Team/Protect-Your-Moa#scroll-license-information) |  | |
| Puzzles Lib | Fuzs | MPL-2.0 | MPL-2.0 | — | [Modrinth](https://modrinth.com/mod/puzzles-lib) |  | |
| Pylons |  | All Rights Reserved | All Rights Reserved | — | [Modrinth](https://modrinth.com/mod/pylons) |  | |
| Quark | Vazkii, WireSegal, MCVinnyq, Sully | See linked terms ⚠️ | CC BY-NC-SA | — | [Modrinth](https://modrinth.com/mod/quark) |  | |
| QuarryPlus | Kotori316 | LGPL-3.0 | LGPL-3.0 | — | [Modrinth](https://modrinth.com/mod/additional-enchanted-miner) |  | |
| Rainbows | Verph | BSD | BSD | — | [Modrinth](https://modrinth.com/mod/rainboows) |  | |
| Rechiseled | SuperMartijn642 | All Rights Reserved | All Rights Reserved | — | [Modrinth](https://modrinth.com/mod/rechiseled) |  | |
| Rechiseled: Create | SuperMartijn642 | All Rights Reserved | All Rights Reserved | — | [Modrinth](https://modrinth.com/mod/rechiseled-create) |  | |
| Redstone Pen | wilechaote | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/redstonepen) |  | |
| Reese's Sodium Options | FlashyReese | MIT | MIT | MIT | [Modrinth](https://modrinth.com/mod/reeses-sodium-options) |  | |
| Refined Storage | Refined Mods | MIT | MIT | MIT | [Modrinth](https://modrinth.com/mod/refined-storage) |  | |
| Refined Storage - JEI Integration | Refined Mods | MIT | MIT | MIT | [Modrinth](https://modrinth.com/mod/refined-storage-jei-integration) |  | |
| Refined Storage - Quartz Arsenal | Refined Mods | MIT | MIT | MIT | [Modrinth](https://modrinth.com/mod/refined-storage-quartz-arsenal) |  | |
| Regions Unexplored | Apollo, UHQ_Games | All Rights Reserved ⚠️ | MIT | — | [Modrinth](https://modrinth.com/mod/regions-unexplored) |  | |
| Relics | SSKirillSS | All Rights Reserved | All Rights Reserved | — | [Modrinth](https://modrinth.com/mod/relics-mod) |  | |
| reliquified_artifacts | Octo-Studios | All Rights Reserved | All Rights Reserved | — | [Modrinth](https://modrinth.com/mod/reliquified-artifacts) |  | |
| Resourceful Lib | ThatGravyBoat, Epic_Oreo | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/resourceful-lib) |  | |
| Resourcefulconfig |  | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/resourceful-config) |  | |
| Revelationary | DaFuqs | LGPL | LGPL-3.0 | — | [Modrinth](https://modrinth.com/mod/revelationary) |  | |
| RFToolsBase | McJty | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/rftools-base) |  | |
| Rhino | latvian.dev, Mozilla | MPL-2.0 | MPL-2.0 | — | [Modrinth](https://modrinth.com/mod/rhino) |  | |
| Ritchie's Projectile Library | rbasamoyai | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/rpl) |  | |
| Scalable Cat's Force |  | Undeclared | Apache-2.0 | Apache-2.0 | [Modrinth](https://modrinth.com/mod/scalable-cats-force) |  | |
| Searchables | Jaredlll08 | MIT | MIT | MIT | [Modrinth](https://modrinth.com/mod/searchables) |  | |
| SecurityCraft | Geforce, bl4ckscor3, Redstone_Dubstep, and ChainmailPi… | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/security-craft) |  | |
| Silent Gear | SilentChaos512 | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/silent-gear) |  | |
| Silent Lib | SilentChaos512 | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/silent-lib) |  | |
| Silent's Gems | SilentChaos512 | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/silents-gems) |  | |
| Sky Aesthetics | The Stellaris Team | Undeclared ⚠️ | MIT | — | [Modrinth](https://modrinth.com/mod/sky-aesthetics) |  | |
| SmartBrainLib | Tslat | MPL-2.0 | MPL-2.0 | — | [Modrinth](https://modrinth.com/mod/smartbrainlib) |  | |
| Smarter Farmers | MehVahdJukaar | Supplementaries Team License v.1.4 ⚠️ | All Rights Reserved | — | [Modrinth](https://modrinth.com/mod/smarter-farmers-farmers-replant) | Yes — manifest only *(unverified)* | |
| Sodium | JellySquid (jellysquid3), IMS212 | Polyform-Shield-1.0.0 | LicenseRef-Polyform-Shield-1.0.0 | Custom | [Modrinth](https://modrinth.com/mod/sodium) · [Terms](https://github.com/CaffeineMC/sodium/blob/dev/LICENSE.md) |  | |
| Sodium Extra | FlashyReese | LGPL-3.0 | LGPL-3.0 | LGPL-3.0 | [Modrinth](https://modrinth.com/mod/sodium-extra) |  | |
| Sophisticated Backpacks | P3pp3rF1y, Ridanisaurus | All Rights Reserved | All Rights Reserved | — | [Modrinth](https://modrinth.com/mod/sophisticated-backpacks) |  | |
| Sophisticated Backpacks Create Integration | P3pp3rF1y | All Rights Reserved | All Rights Reserved | — | [Modrinth](https://modrinth.com/mod/sophisticated-backpacks-create-integration) |  | |
| Sophisticated Core | P3pp3rF1y | All Rights Reserved | All Rights Reserved | — | [Modrinth](https://modrinth.com/mod/sophisticated-core) |  | |
| Sophisticated Storage | P3pp3rF1y, Ridanisaurus | All Rights Reserved | All Rights Reserved | — | [Modrinth](https://modrinth.com/mod/sophisticated-storage) |  | |
| Sophisticated Storage Create Integration | P3pp3rF1y | All Rights Reserved | All Rights Reserved | — | [Modrinth](https://modrinth.com/mod/sophisticated-storage-create-integration) |  | |
| Sound Physics Remastered | Sonic Ether, vlad2305m, Max Henkel | GPL-3.0 | GPL-3.0 | — | [Modrinth](https://modrinth.com/mod/sound-physics-remastered) |  | |
| spark | Luck | GPL-3.0 | GPL-3.0 | — | [Modrinth](https://modrinth.com/mod/spark) · [Terms](https://github.com/lucko/spark/blob/master/LICENSE.txt) |  | |
| Sparkweave Engine | Up | See linked terms ⚠️ | All Rights Reserved | All Rights Reserved | [Modrinth](https://modrinth.com/mod/sparkweave) |  | |
| Spectral Decorations | Brothers_trouble, Garbage Data, Detrilogue , DaFuqs | LGPL | LGPL-3.0 | LGPL-3.0 | [Modrinth](https://modrinth.com/mod/spectral-decorations) |  | |
| Spectrum | DaFuqs, Azzyypaaras, Noaaan, Electro_593 | LGPL | LGPL-3.0 | — | [Modrinth](https://modrinth.com/mod/spectrum) |  | |
| SpectrumJEI | TheLMiffy1111 | LGPL-3.0 | LGPL-3.0 | — | [Modrinth](https://modrinth.com/mod/spectrumjei) |  | |
| SpiffyHUD | Keksuccino | DSMSLv3 (DON'T SNATCH MA STUFF LI… | LicenseRef-DSMSLv3 | — | [Modrinth](https://modrinth.com/mod/spiffyhud) · [Terms](https://github.com/Keksuccino/Spiffy-HUD/blob/main/LICENSE.md) |  | |
| Stellaris | The Stellaris Team | CC BY-NC-SA | CC BY-NC-SA | — | [Modrinth](https://modrinth.com/mod/stellaris) |  | |
| Storage Drawers | Texelsaur | MIT | MIT | MIT | [Modrinth](https://modrinth.com/mod/storagedrawers) |  | |
| Structory | Stardust Labs | Stardust Labs License | LicenseRef-Stardust-Labs-License | Custom | [Modrinth](https://modrinth.com/mod/structory) · [Terms](https://github.com/Stardust-Labs-MC/license/blob/main/license.txt) | Yes — with attribution | |
| Structory: Towers | Stardust Labs | Stardust Labs License | LicenseRef-Stardust-Labs-License | Custom | [Modrinth](https://modrinth.com/mod/structory-towers) · [Terms](https://github.com/Stardust-Labs-MC/license/blob/main/license.txt) | Yes — with attribution | |
| Structurize | LDT Team | GPL-3.0 | — | — | [Home](https://minecolonies.com/) |  | |
| Super Factory Manager (SFM) | TeamDman | MPL-2.0 | MPL-2.0 | — | [Modrinth](https://modrinth.com/mod/super-factory-manager) |  | |
| SuperMartijn642's Config Library | SuperMartijn642 | All Rights Reserved | All Rights Reserved | — | [Modrinth](https://modrinth.com/mod/supermartijn642s-config-lib) |  | |
| SuperMartijn642's Core Lib | SuperMartijn642 | All Rights Reserved | All Rights Reserved | — | [Modrinth](https://modrinth.com/mod/supermartijn642s-core-lib) |  | |
| Supplementaries | MehVahdJukaar, Plantkillable | Supplementaries Team License v.1.5 | LicenseRef-Supplementaries-Team-L… | All Rights Reserved | [Modrinth](https://modrinth.com/mod/supplementaries) · [Terms](https://github.com/MehVahdJukaar/Supplementaries-Team-License/blob/main/LICENSE.md) | Yes — manifest only | |
| TerraBlender | Adubbz | LGPL-3.0 | LGPL-3.0 | — | [Modrinth](https://modrinth.com/mod/terrablender) · [Terms](https://github.com/Glitchfiend/TerraBlender/blob/TB-1.19.3-2.1.x/LICENSE) |  | |
| Tesseract API | Swedz | MIT | MIT | MIT | [Modrinth](https://modrinth.com/mod/tesseract-api) |  | |
| The Aether | AlphaMode, baguchi, bconlon, Blodhgarm, Burning Cactus… | LGPL-3.0 ⚠️ | LicenseRef-Custom | — | [Modrinth](https://modrinth.com/mod/aether) · [Terms](https://github.com/The-Aether-Team/The-Aether#scroll-license-information) |  | |
| The Bumblezone | TelepathicGrunt | MIT ⚠️ | All Rights Reserved | All Rights Reserved+LGPL-3.0 | [Modrinth](https://modrinth.com/mod/the-bumblezone) |  | |
| The Roads More Travelled | milkucha | CC BY-NC | CC BY-NC | — | [Modrinth](https://modrinth.com/mod/the-roads-more-travelled) |  | |
| The Twilight Forest | Benimatic, AtomicBlom, Drullkus, Killer_Demon, quadrax… | LGPL-2.1 | — | — | [Home](https://www.curseforge.com/minecraft/mc-mods/the-twilight-forest) |  | |
| The Undergarden | quek | MIT ⚠️ | All Rights Reserved | — | [Modrinth](https://modrinth.com/mod/the-undergarden) |  | |
| Theurgy | Kli Kli | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/theurgy) · [Terms](https://github.com/klikli-dev/theurgy#licensing) |  | |
| Theurgy KubeJS | Kli Kli | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/theurgy-kubejs) · [Terms](https://github.com/klikli-dev/theurgy-kubejs/blob/main/README.md#licensing) |  | |
| Titanium | TheCodedOne, Buuz135 | LGPL ⚠️ | MIT | LGPL-3.0 | [Modrinth](https://modrinth.com/mod/titanium) |  | |
| Tough As Nails | Adubbz, Forstride | All Rights Reserved | All Rights Reserved | — | [Modrinth](https://modrinth.com/mod/tough-as-nails) |  | |
| Towntalk | LDTTeam | All Rights Reserved | — | — | — |  | |
| Trash Cans | SuperMartijn642 | All Rights Reserved | All Rights Reserved | — | [Modrinth](https://modrinth.com/mod/trash-cans) |  | |
| TrashSlot | BlayTheNinth | All Rights Reserved | All Rights Reserved | All Rights Reserved | [Modrinth](https://modrinth.com/mod/trashslot) · [Terms](https://mods.twelveiterations.com/permissions) | Ask — see permissions page | |
| Traveler's Titles | YUNGNICKYOUNG | LGPL-3.0 | LGPL-3.0 | LGPL-3.0 | [Modrinth](https://modrinth.com/mod/travelers-titles) |  | |
| Tree Tap | LobsterJonn | All Rights Reserved | — | — | — |  | |
| Tropicraft | Cojomax99, Corosus, tterrag | MPL-2.0 | MPL-2.0 | — | [Modrinth](https://modrinth.com/mod/tropicraft) |  | |
| UI Library Mod | LDT Team | GPL-3.0 | — | — | — |  | |
| UniLib | CDAGaming | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/unilib) · [Terms](https://gitlab.com/CDAGaming/UniLib/-/blob/main/LICENSE) |  | |
| Universal Grid | Ultramega | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/universal-grid) |  | |
| Uranus | IAFEnvoy | LGPL-3.0 | LGPL-3.0 | — | [Modrinth](https://modrinth.com/mod/uranus) |  | |
| Utilitarian | LobsterJonn | All Rights Reserved | All Rights Reserved | — | [Modrinth](https://modrinth.com/mod/utilitarian) |  | |
| Valhelsia Core |  | All Rights Reserved ⚠️ | LicenseRef-Custom | — | [Modrinth](https://modrinth.com/mod/valhelsia-core) |  | |
| Vampire Spells Addon | xsharov | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/vampirism-irons-spells-compatibility) |  | |
| Vampire's Delight | GridExpert | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/vampires-delight) |  | |
| Vampires Need Umbrellas | focamacho | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/vampires-need-umbrellas) |  | |
| Vampirism / Teamlapen Library | maxanier, cheaterpaul | LGPL-3.0 | LGPL-3.0 | — | [Modrinth](https://modrinth.com/mod/vampirism) |  | |
| Vampirism Integrations | Maxanier | LGPL-3.0 | LGPL-3.0 | — | [Modrinth](https://modrinth.com/mod/vampirism-integrations) |  | |
| Variants&Ventures | Faboslav | CC BY-NC-ND ⚠️ | LicenseRef-CC-BY-NC-ND-4.0 | — | [Modrinth](https://modrinth.com/mod/variants-and-ventures) · [Terms](https://raw.githubusercontent.com/Faboslav/variants-and-ventures/master/LICENSE.txt) |  | |
| Visual Workbench | Fuzs | MPL-2.0 | MPL-2.0 | All Rights Reserved+LGPL-3.0 | [Modrinth](https://modrinth.com/mod/visual-workbench) |  | |
| Voltaic | aurilisdev, skip999 | AURILISDEV LICENSE | LicenseRef-AURILISDEV-LICENSE-1.0… | — | [Modrinth](https://modrinth.com/mod/voltaic) · [Terms](https://github.com/aurilisdev/Electrodynamics/blob/1.20/LICENSE.txt) |  | |
| WaveyCapes | tr7zw | tr7zw Protective License | LicenseRef-tr7zw-Protective-Licen… | MIT | [Modrinth](https://modrinth.com/mod/wavey-capes) · [Terms](https://github.com/tr7zw/WaveyCapes/blob/1.18/LICENSE) | Yes — non-commercial only | |
| Waystones | BlayTheNinth | All Rights Reserved | All Rights Reserved | All Rights Reserved | [Modrinth](https://modrinth.com/mod/waystones) · [Terms](https://mods.twelveiterations.com/permissions) | Ask — see permissions page | |
| Werewolves | cheaterpaul | LGPL-3.0 | LGPL-3.0 | — | [Modrinth](https://modrinth.com/mod/werewolves) |  | |
| Wildfire's Female Gender Mod | WildfireRomeo | LGPL-3.0 | LGPL-3.0 | — | [Modrinth](https://modrinth.com/mod/female-gender) |  | |
| Wireless Chargers | SuperMartijn642 | All Rights Reserved | All Rights Reserved | — | [Modrinth](https://modrinth.com/mod/wireless-chargers) |  | |
| Witchery | mrsterner | All Rights Reserved ⚠️ | LGPL-3.0 | — | [Modrinth](https://modrinth.com/mod/just-another-witchery-remake) |  | |
| Xaero Train Map | 1Foxy2 | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/xaero-train-map) |  | |
| Xaero's Minimap | xaero96 | All Rights Reserved | All Rights Reserved | All Rights Reserved | [Modrinth](https://modrinth.com/mod/xaeros-minimap) |  | |
| Xaero's World Map | xaero96 | All Rights Reserved | All Rights Reserved | — | [Modrinth](https://modrinth.com/mod/xaeros-world-map) |  | |
| XNet | McJty | MIT | MIT | — | [Modrinth](https://modrinth.com/mod/xnet) |  | |
| XTones Reworked | TobsenD | MIT | — | — | — |  | |
| XyCraft Core | Soaryn | All Rights Reserved | — | — | — |  | |
| XyCraft Machines | Soaryn | All Rights Reserved | — | — | — |  | |
| XyCraft Override | Soaryn | All Rights Reserved | — | — | — |  | |
| XyCraft World | Soaryn | All Rights Reserved | — | — | — |  | |
| YetAnotherConfigLib | isXander | LGPL-3.0 | LGPL-3.0 | — | [Modrinth](https://modrinth.com/mod/yacl) |  | |
| YUNG's API | YUNGNICKYOUNG | LGPL-3.0 | LGPL-3.0 | LGPL-3.0 | [Modrinth](https://modrinth.com/mod/yungs-api) |  | |
| YUNG's Better Desert Temples | YUNGNICKYOUNG, Tera | LGPL-3.0 | LGPL-3.0 | LGPL-3.0 | [Modrinth](https://modrinth.com/mod/yungs-better-desert-temples) |  | |
| YUNG's Better Dungeons | YUNGNICKYOUNG, Acarii | LGPL-3.0 | LGPL-3.0 | LGPL-3.0 | [Modrinth](https://modrinth.com/mod/yungs-better-dungeons) |  | |
| YUNG's Better End Island | YUNGNICKYOUNG, Acarii | LGPL-3.0 | LGPL-3.0 | LGPL-3.0 | [Modrinth](https://modrinth.com/mod/yungs-better-end-island) |  | |
| YUNG's Better Jungle Temples | YUNGNICKYOUNG, Tera | LGPL-3.0 | LGPL-3.0 | LGPL-3.0 | [Modrinth](https://modrinth.com/mod/yungs-better-jungle-temples) |  | |
| YUNG's Better Mineshafts | YUNGNICKYOUNG | LGPL-3.0 | LGPL-3.0 | LGPL-3.0 | [Modrinth](https://modrinth.com/mod/yungs-better-mineshafts) |  | |
| YUNG's Better Nether Fortresses | YUNGNICKYOUNG, Acarii | LGPL-3.0 | LGPL-3.0 | LGPL-3.0 | [Modrinth](https://modrinth.com/mod/yungs-better-nether-fortresses) |  | |
| YUNG's Better Ocean Monuments | YUNGNICKYOUNG, Tera | LGPL-3.0 | LGPL-3.0 | LGPL-3.0 | [Modrinth](https://modrinth.com/mod/yungs-better-ocean-monuments) |  | |
| YUNG's Better Strongholds | YUNGNICKYOUNG, Acarii | LGPL-3.0 | LGPL-3.0 | LGPL-3.0 | [Modrinth](https://modrinth.com/mod/yungs-better-strongholds) |  | |
| YUNG's Better Witch Huts | YUNGNICKYOUNG, Acarii | LGPL-3.0 | LGPL-3.0 | LGPL-3.0 | [Modrinth](https://modrinth.com/mod/yungs-better-witch-huts) |  | |
| YUNG's Bridges | YUNGNICKYOUNG | LGPL-3.0 | LGPL-3.0 | LGPL-3.0 | [Modrinth](https://modrinth.com/mod/yungs-bridges) |  | |
| Zero CORE 2 | ZeroNoRyouki | All Rights Reserved | All Rights Reserved | MIT | [Modrinth](https://modrinth.com/mod/zerocore) |  | |
| Zeta | Vazkii, quat, IThundxr, Siuol, wiresegal, MehVahdJukaar | See linked terms ⚠️ | CC BY-NC-SA | — | [Modrinth](https://modrinth.com/mod/zeta) · [Terms](https://github.com/VazkiiMods/Zeta/blob/main/LICENSE.md) |  | |

⚠️ = jar and Modrinth disagree on this mod's license. *(unverified)* = permission inferred from a sibling mod by the same author rather than read from this jar.

---

## Why this file is like this

Most modpacks ship a LICENSE.md that says "all mods belong to their respective authors" and calls it a day. That sentence is true, and it is also doing absolutely nothing.

It doesn't tell you which of these 112 mods are All Rights Reserved. It doesn't catch the 17 jars that contradict their own license file, or the 57 that disagree with their own store page. It doesn't notice that three authors granted modpack permission *conditionally* and that we're now on the hook for those conditions. It definitely doesn't tell a player whether the pack they just installed is built on anything sketchy.

So we went the other way. Every jar in the pack gets cracked open, every license string gets read, every file gets hashed and matched against its published listing, and anything that disagrees gets written down instead of quietly rounded off. Then a human reads the weird ones.

Is a 496-row license audit overkill for a Minecraft modpack? Yeah, probably. But "all mods belong to their respective authors" is the licensing equivalent of a shrug, and we'd rather do the boring version properly — for the authors who deserve to know their terms are being honoured, and for you, so you can actually check instead of taking our word for it.

Covering all pages. Every single one of them. On purpose.

---

## Notes and caveats

- **License strings in jars are free text, not SPDX.** Authors write whatever they like in the `license` field, and the NeoForge MDK ships `All Rights Reserved` as its placeholder — so an ARR toml is frequently boilerplate rather than a decision. Values here are normalized into families for readability; exact strings are preserved in `reports/mod-licenses.csv`.
- **A license is not a distribution policy.** CurseForge and Modrinth both carry a separate per-project third-party distribution setting. A permissively licensed mod may have it switched off, and a restrictively licensed one may have it on.
- **Code and assets are often licensed separately.** Several mods here license their code openly while reserving all rights to textures, models and sounds.
- **Some licenses are revocable or subject to change.** At least one license in this pack reserves the right to alter its terms at the author's sole discretion. This audit reflects the terms shipped with the mod versions listed, at the pack version stated above, and should be regenerated each release.
- **This document is generated, then reviewed.** The mod list, licenses and links come from an automated audit of the actual jars; the permission columns are human judgement. Both inputs are committed to the repo — see *Check our work* above — so the generated half is independently verifiable and the judgement half is at least visible.
- **We are not lawyers.** We are people who wrote a PowerShell script at an unreasonable hour. This document records what we found and what we were told; it is not legal advice, and if you're making decisions that need legal advice, go get some.

If you read this whole thing: respect. Genuinely. Go play the pack.

*Generated from `reports/mod-licenses.csv` and `reports/license-texts/` on 2026-08-13 for pack version `v0.0.1-Alpha`. Regenerate with `.\Get-ModLicenses.ps1 -VerifyModrinth -DumpLicenseFiles`.*

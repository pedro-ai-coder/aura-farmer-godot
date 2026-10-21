# G0.2 — Phaser-to-Godot migration source audit

**Evidence date:** 21 October 2026. **Read-only audit:** no changes were made to the source Phaser repository. **Status:** source contracts and Git object inventory captured; engine/gameplay migration and runtime tests are *not* completed. `docs/GDD.md` remains the sole authoritative gameplay and visual specification. This document is evidence and an implementation dependency list, **not a second GDD**.

## Frozen repository baselines

| Target | Reference | State |
|---|---|---|
| Phaser source | [`pedro-ai-coder/aura-farmer`](https://github.com/pedro-ai-coder/aura-farmer/tree/fdbc67b9d79b1d2bfbbcaad40305da1677bc626f) | `main` HEAD = `fdbc67b9d79b1d2bfbbcaad40305da1677bc626f`; read-only |
| Godot destination | [`pedro-ai-coder/aura-farmer-godot`](https://github.com/pedro-ai-coder/aura-farmer-godot/tree/14cbd1cc82f4b1eedf64e02164fee5f775c3be84) | Bootstrap `main` HEAD = `14cbd1cc82f4b1eedf64e02164fee5f775c3be84`; migration not started |
| Godot platform strategy | [GDD platform amendment PR #1](https://github.com/pedro-ai-coder/aura-farmer-godot/pull/1) | Separate PR; do not assume merged |
| Expanded Ruin Alley | [Phaser PR #102](https://github.com/pedro-ai-coder/aura-farmer/pull/102) | **OPEN / DRAFT / NOT MERGED**, head `cb5a9a5dc9154a7365fa9971e7e62a0e9ba5ecb6` |

The source PR #102 changes **17 paths**, including `src/game/simulation/world.ts`, `run.ts`, camera/input/rendering and new world-expansion tests/documentation. Do **not** port its new world geometry as though it is already on Phaser `main`. Re-evaluate the PR state and its tests immediately before choosing the migration baseline. PR #100 (renderer efficiency) and PR #101 (camera follow) are already merged in the pinned source baseline.

## 1. Catalog and gameplay migration matrix

| Area | Source-of-record code at pinned commit | Observed baseline | Porting requirement |
|---|---|---|---|
| Hero IDs | `src/game/catalog/content.ts` | **9 stable IDs**: `sigma`, `nerd`, `six-seven`, `cool-kid`, `ohio`, `rizzler`, `alpha`, `fanum`, `beta` | Preserve all IDs and unlock references; only Sigma, Cool Kid and Alpha Chad are playable in the current demo |
| Weapons | `src/game/catalog/content.ts` (`WEAPONS`) | **9 weapons**; role-aware; starter uses weapon slot | Port IDs, coefficients, rarity/level caps and targeting together, not independently from UI |
| Passives | `src/game/catalog/content.ts` (`PASSIVES`) | **23 of 28** in current solo demo | Explicitly preserve the subset boundary; the five absent passives are *not* secretly enabled |
| Equipment | `src/game/catalog/content.ts`, `src/game/simulation/inventory.ts` | **3 weapon + 5 passive slots**, rarity caps `4/3/2/1` | Validate caps and item compatibility deterministically |
| Encounters | `src/game/catalog/enemies.ts` | **17 enemy-kind IDs** (includes bosses/events and terminal); **4 timed boss events** | Preserve definitions and event schedule; don't confuse enemy families with animation sheets |
| Timeline | `src/game/catalog/content.ts`, `src/game/simulation/run.ts` | **5 waves × 180 seconds**, boss at 900 seconds and berserk after 180 seconds | Port paused simulation time separately from OS/frame clock |
| Determinism | `src/game/simulation/world.ts`, `run.ts` | Seeded RNG and explicit simulation logic | Establish seed-for-seed parity fixtures before introducing new features |
| Solo world on main | `src/game/simulation/world.ts` | `WORLD = 1448 × 1086`; floor polygon and **2 circular covers** | Preserve the approved original map, but reconcile with PR #102 before choosing the expanded world baseline |
| Presentation | `src/browser/scene.ts`, `src/browser/app.ts` | Phaser canvas, runtime PNGs, camera, UI and browser inputs | Implement Godot rendering and platform-neutral simulation separately |

**Port order:** (1) stable IDs/catalog and save adapter, (2) deterministic simulation clock/RNG, (3) world and collision baseline after PR #102 reconciliation, (4) current approved characters/art, (5) full solo run, (6) Web/Android/iOS platform gates. No new characters, new art, paid CI or change of approved mechanics.

## 2. Art and asset inventory

Source inventory: **27 tracked asset files**, of which **21 are PNGs** totaling **42,001,152 bytes** (~40.1 MiB): **10 approved original/reference PNGs** under `public/assets/cartoon/option-a-v1` and **11 runtime PNGs** under `public/assets/runtime`. Six other files contain manifests, prompts and gallery data. Every path, byte count, Git blob SHA and available manifest SHA-256 is recorded in [`G0_2_ASSET_INVENTORY.json`](G0_2_ASSET_INVENTORY.json).

| Asset file (relative to `public/assets/`) | Bytes | Git blob SHA-1 prefix | Manifest coverage |
|---|---:|---|---|
| `cartoon/option-a-v1/characters/alpha.png` | 1,454,663 | `6b49950d0879…` | Declared in metadata |
| `cartoon/option-a-v1/characters/cool-kid.png` | 1,087,875 | `aba1e58dc5f6…` | Declared in metadata |
| `cartoon/option-a-v1/characters/sigma.png` | 923,902 | `3191956dd3ec…` | Declared in metadata |
| `cartoon/option-a-v1/enemies/big-hater.png` | 1,136,254 | `fd66b4c1754b…` | Declared in metadata |
| `cartoon/option-a-v1/enemies/hater.png` | 947,651 | `6b32fcb2dc95…` | Declared in metadata |
| `cartoon/option-a-v1/enemies/phone-guy.png` | 784,261 | `e708780cd1c2…` | Declared in metadata |
| `cartoon/option-a-v1/maps/crown-court.png` | 3,378,467 | `72843af688a4…` | Declared in metadata |
| `cartoon/option-a-v1/maps/ruin-alley.png` | 3,259,712 | `d602e9f1ca3f…` | Declared in metadata |
| `cartoon/option-a-v1/maps/toxic-garden.png` | 3,447,650 | `fff6c9ec1ed4…` | Declared in metadata |
| `cartoon/option-a-v1/ui/main-menu.png` | 3,002,230 | `c186a4c8c21f…` | Declared in metadata |
| `runtime/alpha-atlas.png` | 2,657,600 | `a69db3635734…` | Declared in metadata |
| `runtime/alpha-rear-v2.png` | 1,475,395 | `4fde150888b8…` | Not in runtime manifest |
| `runtime/cool-kid-atlas.png` | 2,433,350 | `d35059aad06a…` | Declared in metadata |
| `runtime/cool-kid-flex-v2.png` | 1,248,342 | `91fb83776d11…` | Not in runtime manifest |
| `runtime/cool-kid-rear-v2.png` | 1,195,136 | `b4a69481b8b6…` | Not in runtime manifest |
| `runtime/enemies-a-v2.png` | 2,228,162 | `6617f8f762ba…` | Not in runtime manifest |
| `runtime/enemies-b-v2.png` | 2,097,523 | `3b59147c26b8…` | Not in runtime manifest |
| `runtime/enemies.png` | 2,305,628 | `6a735dbb233c…` | Declared in metadata |
| `runtime/events-v2.png` | 2,567,969 | `7beb2e2d1aee…` | Not in runtime manifest |
| `runtime/haters-v2.png` | 2,319,510 | `7f35a57dda8a…` | Not in runtime manifest |
| `runtime/sigma-atlas.png` | 2,049,872 | `226e6c791005…` | Declared in metadata |

**Findings / cautions:**

- The approved master manifest lists **10** PNG references, but its original `static-art-not-integrated` labels are historical: current source code loads the original Ruin Alley and runtime sprite variants. Do not infer current usage solely from the manifest status.
- The runtime manifest covers **4** images, while the directory contains **11** runtime PNGs. Preserve all 11 until the renderer's load paths and animation slice definitions have been reconciled; never delete assets based on this partial manifest.
- Git blob SHA-1 is **not** PNG SHA-256. Reference manifest SHA-256 is included as metadata for the images it identifies, but was **not rehashed** during this read-only audit.
- Assets have **not** been copied into the Godot repository by G0.2. Before the art-import PR, verify rights/provenance, compare SHA-256 on downloaded files, preserve immutable original masters and review runtime cutouts/foot pivots. Avoid assuming JSON image grids represent final Godot sprite coordinates.
- Approved art direction is **Cartoon Arcade / Option A**. The existing Godot circle and grid are diagnostic placeholders, not replacements for approved assets.

## 3. Persistence migration matrix

Source: `src/browser/save.ts` and its regression suite `tests/persistence.test.ts` (pinned commit).

| Data | Phaser contract | Godot migration requirement |
|---|---|---|
| Current profile | localStorage key `aura-farmer:profile:v2`; root `version: 2` | Parse/export version explicitly; retain original JSON and validate data |
| Legacy profile | `aura-farmer:profile:v1`; root `schemaVersion: 1` | Import legacy only when no valid v2 exists; retain untouched v1 snapshot |
| Hero selection | `selected`: one of `sigma`, `cool-kid`, `alpha` | Validate against currently playable hero IDs; preserve all 9 in `unlocked` |
| Unlocks | `unlocked: CharacterId[]` | De-duplicate, whitelist stable IDs and preserve valid unlocks |
| Aggregates | `xp`, `wins`, `runs` | Reject negative/non-finite values; never recompute totals by just counting last-40 results |
| Preferences | `settings.reducedMotion`, `settings.sound` | Preserve semantics and safe defaults on each platform |
| Result history | Last **40** `results` with stable `id`, hero, outcome, time, wave, level and combat stats | Preserve valid records; de-duplicate IDs, normalize missing numeric fields and cap history |
| Legacy snapshot | Optional `legacy` object inside v2 | Preserve opaque historical data without executing it |
| Run state | Starter equip, in-run aura/HP/upgrades | **Do not carry current-run power to another run**; profile only |

**Critical distinction:** browser `localStorage` is not accessible inside an unrelated Android or iOS installation. A **user-authorized JSON import/export** is a candidate implementation strategy, not a feature already approved/implemented. Do not claim seamless cross-device sync or auto-import. Test malformed, duplicate, unknown-ID and old-version payloads before the save adapter is accepted. No network access or sensitive user data is required for this audit.

## 4. Gaps and risk register

| Risk | Importance | Required follow-up |
|---|---|---|
| PR #102 map work is not yet on source `main` | High | Refresh PR status/test evidence; choose and pin the world baseline, not a mixture of branches |
| Godot bootstrap contains only a diagnostic movement/camera scene | High | Port behavior from source and validate equivalence before demo claims |
| Android/iOS are not validated | High | Native export, touch, lifecycle, safe areas, performance and real-device full runs |
| No save bridge exists from browser storage to Godot | High | Design versioned, lossless, explicit user-consent import path |
| Runtime manifest does not list seven runtime PNGs | Medium | Preserve all; derive complete live asset map from code and actual files |
| Godot executable unavailable during this audit | Medium | Run `scripts/validate.sh` and platform exports on a machine with the engine installed |
| Existing Phaser docs and new GDD may describe different historical delivery scopes | Medium | Use Godot GDD §23 once its dedicated PR merges; retain Phaser revision as reference only |

## 5. Evidence and verification limits

This audit is built from **GitHub Git tree objects, raw source file text, approved/runtime manifests and the live PR #102 metadata**. Snapshot references and Git SHA values make it reproducible. Inventory counts and manifest coverage have been checked against the pinned tree. No asset binaries were downloaded, no Phaser tests were rerun, and no Godot editor, Web export or native device tests were run. The resulting matrix is fit for planning the **next** migration PR, not proof that a playable port exists.

**Next implementation milestone:** G1.1 shared catalogs and rarity/slot contracts, after approving the GDD platform amendment and determining the source map baseline.

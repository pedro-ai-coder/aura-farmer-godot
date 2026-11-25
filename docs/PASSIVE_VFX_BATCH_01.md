# Premium Passive VFX Batch 01

Status: **PROPOSED / EXPERIMENTAL — NOT APPROVED ARTWORK — DO NOT MERGE OR DEPLOY TO PRODUCTION**.

Baseline: verified production `125604db7f78ae9ee48e82c63e37eea8a7ac57f4` (No U V4, Game #165). No U V4 and Six → Seven V3 scripts/art remain untouched. This branch only extends presentation and isolated review controls.

| Stable ID | Exact unchanged purpose | Proposed visual identity | Immediate controlled input |
| --- | --- | --- | --- |
| `big-chad` | Tank rare; first combat shield at 10 s, then every 10 s; 5% max HP at L1 × support, 4 s, shared cap/refresh | Chad Armor: orange/ivory ink-cut armor facets; fast snap, remaining-shield mantle, actual absorption fracture and expiration | Starts at active time 8.75 s; real first shield at 10 s, then controlled damage |
| `too-sigma` | Legendary; surviving crossing below 25% HP grants 25% max HP shield × support for 5 s, 60 s recovery; no revive | Last Stand: anchored violet bastion, tall open crest; actual shield state, fracture and release | Starts at 32% HP; real incoming damage crosses threshold at 1.25 s |
| `so-back` | Epic; surviving crossing below 30% HP grants 10% shield/3 s and 10% max HP × support over five healing ticks, 45 s recovery | Comeback Surge: rising mint/coral plume, only on effective healing; shield remains in authoritative HUD | Same controlled crossing; first heal one second later, then five actual ticks |
| `w-squad` | Legendary; +25% support permanently; Flex grants +10% weapon damage for 6 s | Winning Crew: linked cyan/amber pennant crest, outward snap and live buff marker; no allies | Real Flex at 1.25 s using controlled full Aura |
| `absolute-cinema` | Legendary; +25% weapon damage; another +20% additive during Flex; no bonus to Flex damage | Cinematic Flex: diagonal ink/amber clapper snap and restrained active imprint; no camera or time changes | Real Flex at 1.25 s |

Canonical mechanics: `docs/GDD.md` §5.10, `solo_passive_rules.gd`, existing `solo_run.gd` resolvers. Art source/hash/tool/exact prompts: `assets/experimental/passive-batch-01/manifest.json` and `prompts.json`. Five independent original generated RGBA PNGs; no approved artwork replaced. Built-in image_gen used, no CLI/API service or new dependency.

## Playable review

Garage → Play → hero/map picker. Choose either map, NORMAL/DENSE, passive, and CANDIDATE/PRODUCTION BASELINE; start. Controlled builds use Alpha Chad so Big Chad is legitimately class-eligible. The in-run label names treatment, exact real effect, HP/shield and event count. **R** immediately retries the same scenario. Existing pause/settings provide Reduced Motion and sound/mute.

Combined build = Big Chad + So Back + W Squad, one legendary. It starts at 8.75 s, lets Big Chad actually grant protection, then applies threshold/Flex inputs at elapsed 1.45 s. It intentionally preserves shield-cap competition and absorption order. Stationary real NPC/Beta enemies (5 normal, 36 dense, cover-legal placements) provide repeatable combat without requiring survival skill. This is an explicitly controlled QA scenario, not a normal progression or balance proposal. No simulated allies/multiplayer or unsupported damage protection is introduced.

## Implementation and isolation

`passive_batch_feedback.gd` extends the existing observer and consumes actual shield grant/absorption, effective healing and Flex callbacks. At most eight short-lived sprites; individual assets, timing, silhouettes and sound profiles. State markers read actual remaining shield/deadlines/Flex timers; Reduced Motion disables travel/rotation/scaling while retaining state and fades. No authoritative RNG use. Existing eight-voice mixer, mute and modal suspension remain authoritative.

Reuse the existing QA Recorder implementation through a byte-identical review-only copy, preserving its bounded in-memory trace and honest wall-interval metric. No recording/export writes to player storage. The Garage scene runs the actual game. Review resource imports are gated to this exact branch's Vercel **Preview**; ordinary source exports and any production target exclude every batch script, PNG, manifest and imported texture. No production release is authorized.

## Executed development evidence

- After all five generated sprites were imported, targeted test passed 23,040 exact state/RNG/profile paired frames across six selections, two maps, normal/dense and Reduced Motion. Five effective heal ticks, zero outcomes silent, bounded effects, expiry, retry/menu isolation and zero QA profile writes checked.
- Eleven native RX 6800 XT scenarios captured and internally inspected, including all individual treatments and combined baseline/candidate/reduced on both maps. Initial Dense single-trial frame/burst P95 ms: Alley baseline 4.344/4.136, candidate 4.646/4.930; Factory baseline 4.011/4.061, candidate 3.854/3.533. These development measurements precede final per-passive timing refinement; final candidate results are recorded separately. No mobile or input-latency certification.
- Real experimental PCK includes all five sprite imports, manifest and three isolated review scripts, preserves both approved VFX families and excludes test/QA scenes. Final ordinary PCK, complete mandatory suite, CI and protected Web smoke are release-to-review gates recorded in the PR and append-only workspace audit.

## Append-only audit

- 2026-11-25: Began after Workstream A production verification on both maps. Verified identity pedro-ai-coder, email pestrela@proton.me; isolated branch from exact production merge. Read existing art, QA, mixer and passive observer abstractions; no additional framework/repository/service.
- Generated five independent experimental sprites using built-in image_gen with transparent backgrounds. Preserved original files and exact copied hashes/prompts. Inspected alpha, center transparency and in-game frames. Approval remains pending.
- First targeted run overlapped generation/import of the final sprite; engine emitted missing-resource errors despite test exit 0. That run is INVALID, never a full PASS. Repeated after all assets were present/imported: no errors, 23,040 frames PASS. Logs retained.
- Combined initial ordering would let shield-cap competition suppress Big Chad. Delayed only the controlled combined input to 1.45 s so the real first shield grants at 10 s; canonical damage/shield rules unchanged. Final test verifies every selected treatment resolves real events. No gameplay tuning or new canonical decision.

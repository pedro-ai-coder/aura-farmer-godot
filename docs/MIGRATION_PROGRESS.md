# Godot migration progress

## Historical repository baseline (before G1.10)

- Godot main: `ba7c43684d176a06c31a12487badb0cccab966d4`.
- Phaser main inspected: `fdbc67b` (reference only; unchanged).
- PR #17 is merged; no open destination PRs were returned before this iteration.
- The canonical Godot GDD remains authoritative. Phaser includes later recovery/balance work while Godot GDD Appendix C still labels P1–P8 proposals. Those features must not be copied automatically.

## G1.10 history: player projectile travel and weapon timing

Replaces instant No Cap/Ratio Blaster damage with moving projectiles, cover rejection, finite range, piercing limits and per-projectile hit memory. Rendering follows projectile positions. Adds arrival/duplicate-hit/restart/cover regression coverage and updates the original instant-hit smoke assertion.

Validation on 22 October: local Godot 4.7.2 now starts after restoring the complete 146,414,384-byte executable from the SHA-verified archive. A truncated Alpha atlas was restored from the pinned Phaser Git object; all 18 assets pass the manifest hashes. Invalid generated import metadata was removed and regenerated. The full local `scripts/validate.sh` suite passes, including projectile travel and new delayed-area regressions. The earlier engine crash was an incomplete local executable, not a confirmed engine defect.

Additional combat fixes: Brainrot marks a fixed position and resolves after 0.45s; Ban Hammer resolves after its 0.30s windup; Keyboard Warrior and Chad Hands divide damage across the approved two impact times. Shared activation state prevents duplicated primary procs. Origins and directions remain fixed for pending attacks; pause freezes them and restart discards them. Brainrot/Ban warnings describe the real pending geometry.

Further weapon coverage now includes delayed legendary Ratio shots, No Cap line explosion, shared-hit Feed side impacts, Keyboard/Hammer finishers, successful-hit Chad slam conversion, enhanced Grass, weapon shield refresh/expiry, and Personal Space weakness. Secondary hits do not trigger primary procs. All nine weapon IDs have behavioral coverage; this does not establish complete parity. Remaining combat gaps include manual aim, boss stagger, exact area active windows, full passive interactions and all event/boss patterns.

Local `scripts/validate.sh` passed again with `test_legendary_combat.gd`, covering all nine weapons, secondary damage/proc isolation, shield lifetimes/absorption and boss-transition cleanup.

The previous PR head `863e0343a10b5adc86b4180fe8eee8d355f9057e` passes hosted Godot CI. The updated commit still requires hosted checks and interactive preview verification before merge. Vercel connector access returns 403 at `read_protection_bypass`. Browser authentication is now complete, but the authenticated preview reports missing WebGL2 in the remote browser before the game can start. This is a browser execution limitation, not evidence of a game rendering defect. No native, performance, full-run or visual acceptance is claimed.

## Current integration status — 22 October 2026

PRs [#18](https://github.com/pedro-ai-coder/aura-farmer-godot/pull/18), [#19](https://github.com/pedro-ai-coder/aura-farmer-godot/pull/19), [#20](https://github.com/pedro-ai-coder/aura-farmer-godot/pull/20), [#21](https://github.com/pedro-ai-coder/aura-farmer-godot/pull/21), [#22](https://github.com/pedro-ai-coder/aura-farmer-godot/pull/22) and [#23](https://github.com/pedro-ai-coder/aura-farmer-godot/pull/23) were integrated after local Godot execution, hosted Godot CI and Vercel builds passed. Entries below retain the history of each scoped iteration; statements describing the next iteration are historical.

| Area | Implemented logic and automated evidence | Remaining acceptance |
|---|---|---|
| Nine weapons | Moving projectiles, cover/range/pierce, delayed and paired areas, legendary transformations, active windows and proc isolation | Visual timing and normal-play balance |
| Passives, Aura and Flex | Approved 23-passive solo subset, acquisition/removal clocks, additive and strongest-source stacking, timed shields, primary caps and three starter Flexes | Human build/interactions review |
| Heroes and aiming | Stable target ties, manual aim, Sigma lock, Cool Kid movement/contact and Alpha taunt/slams | Desktop/mobile feel and feedback |
| Enemies and bosses | Bestiary patterns, independent events, terminals, threshold latches, bounded adds, expanding rings, stagger and recoverable berserk | Full normal run and difficulty tuning |
| Menus/profile | Explicit confirmations, replacement cancellation, pause/exit/retry, preferences, v2 persistence, legacy migration and copy/paste transfer | Responsive presentation and real browser storage/device lifecycle |
| Approved assets | All 18 manifest hashes and texture loading verified; 17 enemy animations available | Direction/state/timing, audio and visual acceptance |
| Mobile controls | Pointer ownership, release/focus/modal cleanup; best-effort Web fullscreen/landscape | Real devices, safe areas and denied-fullscreen fallback |
| Performance | Controlled 300-enemy/150-initial-projectile headless fixture | Rendered FPS, sustained density and full-run memory |
| Exports | Hosted Web build; native presets prepared without credentials | SDK/templates, identities/signing and physical Android/iOS tests |

The owner explicitly deferred visual validation. The authenticated remote browser lacks WebGL2. Green automated checks do not establish visual, device, balance or full migration acceptance. Native readiness and exact test limits are documented in [NATIVE_READINESS.md](NATIVE_READINESS.md). Canonical proposal-only unlock thresholds and utility drops remain disabled. Phaser and the canonical GDD are unchanged.

## G1.11 — Boss and event logic

PR #18 merged as `883748cbef0495d93f877bcd604635232366990b` after hosted Godot CI and Vercel build passed. The owner explicitly deferred visual validation and authorized continued logic integration on 22 October. Browser WebGL2 remains unavailable; this is not a blocker for authorized logic work.

Next iteration adds source-attributed hazards, expanding rings with a 70-degree safe gap, one hit per ring, 20/s stagger contribution cap, three-second exposure and refill lock, berserk regeneration suspension, persistent health thresholds, bounded non-farmable adds, Hype Bot exposure, independent event timers, Mod half-health reinforcements and Doomscroll terminals. Tests distinguish expired/preparing/active attacks and independent event deadlines. Full source parity and visual/device/performance acceptance remain pending.

## G1.12 — Save contract and profile lifecycle

PR #19 merged as `ae5441770a6f2ab7a706a8299280e9370c8a8dd5` after hosted CI and Vercel build passed.

The next iteration uses the Phaser profile v2 schema/key on Web and an atomic native JSON file. It preserves historical unlock IDs, settings, totals, bounded unique result history, untouched Phaser v1 snapshots and the previous Godot slice profile. Only won/lost results count; abandoned/in-progress runs cannot progress the profile. Per-run damage, effective healing, absorbed shielding and Flex counts reset on restart. Storage failure does not prevent play. New unlock thresholds remain disabled because GDD 7.1 labels them proposed.

Same-origin browser storage can be migrated automatically. The Godot host cannot read Phaser storage from a different origin; no cross-origin access or paid cross-save backend is introduced. A transferable save/import interface still requires integration before cross-host migration can be claimed complete.

Regression coverage includes legacy snapshots, corrupted/duplicate records, preserved totals beyond 40 retained results, native atomic round trips, storage failure and duplicate terminal callbacks. Validation phases now have explicit timeouts so a script parse failure cannot leave CI hanging indefinitely. Visual/device acceptance remains deferred.

## G1.13 — Run progression and passive lifecycle

PR #20 merged as `eeafe883f35260413122ff7e293ca4ff5ac40af4` after hosted CI and Vercel build passed.

Next corrections: fixed simulation substeps, immediate pause for transition choices, complete XP collection at the boss transition, level-25 recovery with its 20-second lock, rolling one-second primary Aura cap, linear max-HP passive levels, removal of passive effects/stacks without resetting cooldowns, periodic timers starting at acquisition, timed defensive shield sources, and permanent frequency plus the strongest temporary buff. Weapon damage grouping follows Phaser's level base power and additive weapon bonuses. New-card/upgrades/promotions validate their old inventory state and reject duplicates or wrong equipment types.

Visual validation remains deferred by owner authorization; no performance or native acceptance is inferred from these regression tests.

## G1.14 — Hero traits, Flex damage and aiming

PR #21 merged as `2a95956f742200ba5750af4bf4fe68863b4816f8` after hosted CI and Vercel build passed. Next iteration adds stable enemy IDs and tie-breaking, manual mouse direction via M, Sigma target-lock damage, Cool Kid movement bonus and Rampage contact/immunity/boss cap, Alpha's direct-hit charge/taunt and exactly three fixed-step slams, source-aware direct/contact/hazard mitigation, level-scaled Flex/passive damage, and Beta Bot's frontal armor with bounded turning. Visual acceptance remains deferred.

## G1.15 — Menu and profile-transfer logic

PR #22 passed hosted CI and Vercel build and was integrated. Next iteration adds explicit card/replacement confirmation, cancellation without reroll, exit confirmation that returns to pause on Escape, suppressed modal movement, build inspection, fresh result retry, persistent sound/reduced-motion settings and copy/paste v2/v1 save transfer. Import retains the previous Godot profile snapshot and known unlocks; browser-origin isolation is respected. This implements menu behavior using existing controls; visual polish and responsive/device review remain deferred.

## G1.16 — Spawn and integration acceptance contracts

PR #23 passed hosted CI and Vercel build and was integrated. Next iteration adds 0.8-second spawn portals, non-targetable/non-damageable arrival states, the two-elite solo cap and approved elite multipliers/XP with one shield modifier, stable-ID hit memory, touch-accessible replacement cancellation, and best-effort Web fullscreen/orientation handling. Proposal-only Snack/Magnet generation is disabled to honor canonical Appendix C; no approved loot values are expanded.

Controlled three-hero timeline tests cover all wave rewards, real modal confirmations, boss arrival, recoverable berserk, terminal victory and persistence. A synthetic 300-enemy/150-initial-projectile headless fixture prints CPU time but makes no rendered FPS/device claim. Android/iOS preset preparation and explicit missing build/device prerequisites are documented in NATIVE_READINESS.md. Visual, normal-play balance, audio and native/device acceptance remain outstanding.

## G1.17 — Committed ranged aim and damage sources

PR #24 was integrated as `727a9ee6f1cd45c808849144e9ed3e7abf9e3f4b` after local and hosted Godot validation plus Vercel build success. Follow-up inspection found that retreating ranged enemies could aim along their movement vector and hostile projectiles used endpoint-only cover collision. The corrections lock aim toward the player, preserve that committed direction, and test the full travel segment against the shared cover geometry. Initial enemy facing points toward the player; Ratio Ram uses the canonical 0.9-second warning. Doomscroller and death-cloud hazards retain their source for damage modifiers after their caster is removed.

The complete local suite passes, including explicit retreat/aim lock, cover tunneling, charge deadline and persistent-source regressions. No new catalog entries, balance values outside the canonical GDD or visual acceptance are introduced.

## G1.18 — Continuous lifecycle and repeated-use regressions

PR #25 was integrated as `1b4471e060cc8620d784731c370619b145136723` after hosted Godot CI and Vercel success. A continuous seeded three-hero fixture subsequently exposed two repeated-use failures: clearing Sigma's target dictionary also cleared the live enemy because the dictionary was shared; normal offer generation treated legendary's absent normal-rarity index as a promotion opportunity. Target release now assigns an empty reference, and normal offers exclude promotions of existing legendaries. Focused regressions guard both failures.

The continuous fixture drives actual movement, spawns, attacks, XP drops, 24 level choices, one legendary, Flex and clean restart with no time jumps or XP injection. It protects the player from damage, feeds 0.25-second frames through the production fixed simulation substeps and explicitly resolves a surviving boss if necessary. Seed 451 reaches level 25 with all three starters. This proves integration rather than normal survival, fairness or balance. No GDD values or catalog scope change.

## G1.19 — Enemy commitment, recovery and breakable links

PR #26 integrated as `06f283ffa0ad38ca1d6492b8327d1577dc121a1d` after hosted Godot CI and Vercel build passed. A final canonical-pattern audit restores Hate Slam tracking until 0.3 seconds before impact followed by its fixed commitment and 1.2-second recovery. Reply Guy pauses for its 1.5-second vulnerable window, and Ohio Express recovers for two seconds after the third charge. No additional vulnerability damage multiplier is invented.

Fanum Leech now creates a target-following link with an 0.8-second warning and three ticks. Leaving 240 units or defeating the caster breaks the entire link; returning cannot reconnect it. The link remains a direct enemy attack for Rampage immunity, while persistent ground zones retain their special-hazard semantics. Leech and Puffer ability damage apply the canonical common-enemy wave scaling once. Existing geometry cues render the link without new artwork.

Focused regressions verify exact lock/recovery boundaries, commitment after player movement, all three ticks, permanent link break and wave-scaled ability damage. Full visual/device/balance acceptance remains pending.

## G2.0 — Static cover artwork and bounded camera (P0)

Baseline: owner-approved recovery amendment on main (`86a9d4f`); no open PRs at inspection. The existing two cover colliders now render exact Phaser enemy-atlas frame 14 at 80×80 with the original (0.5,0.85) pivot. Actors and props sort by foot depth; placeholder contact arcs are removed. The additional original atlas is pinned and hash-verified in the approved-asset manifest. Collision, movement and sightline geometry are unchanged.

Camera framing follows Phaser's landscape targets, uses time-based smoothing, and clamps the complete visible rectangle to the 1448×1086 map at desktop, ultrawide, mobile landscape and portrait aspect ratios. Viewport changes recompute zoom and bounds without moving the player. Regression coverage checks six viewport sizes, corner/edge targets, smoothing invariance, exact atlas frame and preserved cover collision. Local Godot 4.7.2 validation and Web export pass. Interactive screenshots remain under investigation: the remote browser lacks WebGL2, and the local Chromium process currently exits with SIGTRAP before opening a page. No rendered visual acceptance is claimed from headless tests.

P1–P3 recovery is now approved in canonical Appendix C.2 and is the next implementation priority. Prior notes that called these mechanics proposals are historical; P4–P8 remain unapproved.

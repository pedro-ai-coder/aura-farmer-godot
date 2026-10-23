> **Published icon acceptance — 24 October 2026:** #67 is merged and production `ea4633d` was inspected directly: all 37 approved icon textures included, candidate/review resources excluded, all 19 original masters retained. See `docs/art/CLEAN_CUT_PUBLISHED_EXPORT.json`. The 32 existing playable items use live artwork; five approved future-only passives remain unavailable. All 41 Godot phases, 11 Python regressions, CI and export checks passed. Artistic approval is resolved for these exact PNGs; matching Touch Grass v2 SVG/refinements, broader visual parity, joystick #66 implementation and physical/browser acceptance remain separate follow-ups.

> **Current update — 24 October 2026:** The creator explicitly approves 37 exact PNGs: eight V5 weapons, 28 V5 passives and Touch Grass Clean Cut v2. Clean Cut is the selected visual refinement recorded in GDD §26. All selected copies are hash-verified and promoted; 32 current items use live bindings, five future-only passive artworks remain unoffered. See `docs/art/CREATOR_ICON_APPROVAL_2026-10-24.md` and `docs/art/CLEAN_CUT_INTEGRATION_ACCEPTANCE.md`. Earlier zero-approval/blocked statements below are historical checkpoints. Original source isolation and all gameplay rules remain intact.

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

## G2.1 — Approved recovery parity (P1)

PR #29 integrated as `21035987682a31c3233594e3cffb935107dd17ea` after hosted Godot validation and Vercel success. Canonical Appendix C.2 now authorizes Street Snack, Aura Magnet and Safe Spot. One shared seeded roll per eligible kill uses Phaser's exact Mulberry32 arithmetic, 5%/2% normal and 20%/8% elite chances. The five-per-kind limit recycles only the oldest special; XP crystals are preserved. Boss adds, terminals and Big Hater remain ineligible. The RNG algorithm matches JS reference values and exact counts across 10,000 equivalent draws; complete gameplay RNG consumption order is not claimed identical between engines.

Snacks collect within 56U and heal 18% maximum HP, capped. Magnets collect within 72U and consume all existing XP exactly once, including crystals still in a collection-loop snapshot. Safe Spot is fixed at (1100,565), radius 68U, charges for two continuous seconds below full health, heals 25% and recharges for 90 active seconds. Leaving/full health resets charge; pause freezes charge/cooldown; restart clears all recovery state. It remains available during the boss encounter as in Phaser. Healing retains the existing Certified W/W Squad support multipliers, as in Phaser. Original geometric world-space symbols, ready/cooldown progress and bounded collection feedback are restored without new artwork.

Regression coverage includes seeded probability boundaries/counts, long-run availability, special caps without XP loss, snack radius/heal cap, magnet duplicate prevention, station activation/leaving/full-health/cooldown/pause/restart and boss availability. P4–P8 remain disabled. Visual/device acceptance is separate from these simulation tests.

## G2.2 — Cartoon Arcade interface (P2)

PR #30 integrated as `51f1ad7a40ef0ada16ff0d8c28c15a3361496b8a` after hosted CI and Vercel build passed. The interface now uses a reusable paper/ink/gold/teal theme with focus/hover/pressed/disabled states. Home preserves the original logo artwork without duplicate lettering; hero cards select explicitly before Play, and settings/save transfer have their own screen. Normal and legendary cards show original Phaser symbols, names, rarity/level, gameplay descriptions, selection and confirmation. Ordinary equipment offers include current-to-new level/rarity and base damage/cadence comparisons. The desktop legendary grid fits six cards in two complete rows; smaller windows scroll the card area while actions remain fixed.

The HUD separates HP/shield, XP/level, Aura, wave/time, build slots and boss state. Pause/build, options, results, import/export and exit confirmation use the same presentation. Invalid profile imports keep a visible error rather than hiding it behind the new overlay. Gameplay rules, equipment limits and save schema are unchanged. Layout refreshes cache only presentation state; explicit modal updates always reapply layout after legacy control state changes.

Actual 1280×720 Godot captures were produced through Mesa software OpenGL and Chromium software WebGL2. The local Web export started, accepted Play/pause and emitted no page errors. Phaser reference captures use the original local Vite build, with test-only browser request interception matching its existing tests; source files were not edited. Comparison confirms shared artwork, palette and catalog symbols, while Godot's home composition and HUD organization intentionally differ. Captures are staged review evidence, not a human full run or final artistic acceptance. Real mobile devices, native export/signing, hardware FPS and complete animation polish remain unverified.

A separate browser-cache defect was identified: immutable `index.pck` used an unchanged URL across deployments. The next platform pass will version Web output filenames so existing caches cannot conceal updates. Mobile safe areas, short/portrait layouts and fullscreen lifecycle are the next priority.

## G2.3 — Mobile lifecycle and cache-safe Web delivery (P3)

The mobile pass replaces fixed joystick hit regions with viewport/safe-area-aware playfield bounds, preserves one-pointer ownership, clamps the thumb origin, pauses on focus loss and keeps touch camera framing stable after release. Portrait HUD separates rows; equipment badges move above actions on narrow screens. Settings/build content scrolls inside short panels, footer actions stay fixed, and essential touch targets remain at least 44 physical pixels. Selected cards survive resize. Portrait retains a non-blocking rotate hint.

Web fullscreen/orientation is requested by a trusted DOM touch gesture, only when supported and user activation is eligible. Denied/unavailable fullscreen and unavailable/rejected orientation are caught without repeated requests or unhandled promises. Safe-area insets and current viewport dimensions are read from CSS; no iOS orientation capability is assumed. Node regression scenarios cover all outcomes independently of actual browser permissions.

Web exports now use commit-versioned JS/WASM/PCK names and expose build.json. The landing document revalidates, while immutable caching remains safe for versioned payload URLs. This fixes the prior unchanged index.pck URL retaining a year-long browser cache across deployments. No cache clearing or private browser-data deletion is required.

P3 validation: the complete local Godot suite and Node lifecycle scenarios pass. Chromium touch emulation at 915×412 successfully entered fullscreen and locked landscape through an actual trusted gesture, then exercised joystick movement/release, pause, fullscreen exit and resize to a usable 390×844 portrait layout. There was no horizontal page overflow and no page errors. Native software-OpenGL captures cover portrait menus/cards/profile panels/boss/dense states. Browser denial/unavailable branches are simulated unit cases; physical Android/iOS behavior remains unverified. Portrait review found and fixed Pause obscuring Aura and an overlong menu-return caption. Header artwork is cropped proportionally to keep the original logo and avoid presenting embedded decorative menu lettering as extra controls.

The Web build also scans import/export logs and refuses publication on Godot script/resource errors, including errors for which the engine exits with status zero. A malformed HUD indentation was detected by the full suite, corrected and revalidated before publication.

## G2.4 — Authored animation playback and terminal artwork

The presentation audit found stationary heroes incorrectly cycling run poses because the last non-zero input was reused as current motion. Hero playback now uses current input with a travel-based walk clock, direction hysteresis, fixed scale per approved atlas, authored attack/hurt/Flex entry-loop-exit and defeat poses, and the original seven runtime edge mattes. Alpha's impact poses follow only its three real Flex slams. Defeat playback continues after loss without advancing simulation; pause freezes combat effects.

Enemy playback now follows actual travel, facing, attack windup/impact/recovery and stagger. Bounded defeated snapshots play authored fall poses without combat membership or duplicate drops. Silence Terminal uses original enemies.png frame 13 and its original foot pivot instead of a circle placeholder. All source images and gameplay geometry remain unchanged. Regression tests cover priority, timing, pause, blocked travel, clean restart and non-combat death snapshots. The complete 29-phase Godot suite passed, followed by a real official Web export and staged software-OpenGL captures. This is a playback correction, not a claim of complete animation or human-playtest acceptance.

P3 PR #33 integrated as `2e1f07d22160212ca8fe0c1adb35e0cd7ff4ba54` after Godot CI and Vercel passed. The public production domain still returned the older unversioned entry document and 404 for build.json during the subsequent check; merged code is not yet evidence of production promotion. Team-scoped deployment inspection returns 403 for the current connector, so production revision remains an explicit verification gap while independent work continues.

## G2.5 — Seeded integer draw regression

Full-run repetition exposed that PhaserRng.randi_range called unqualified randf(), which Godot resolved to its global built-in rather than the seeded method. Integer draws therefore did not advance the Mulberry32 stream, causing non-repeatable offers and spawn selection. Explicit self.randf() restores the intended shared seeded stream without changing drop rates, catalog legality, enemy statistics or save schema. Regression tests compare integer JavaScript reference values, shared integer/float state, three-role offers and enemy selection independently of global RNG. All 30 Godot phases and official Web export passed; browser touch validation is repeated. Prior full-run observations are retained as pre-fix evidence and must not imply post-fix balance acceptance.

## G2.6 — Acceptance evidence and outstanding deployment access

[RECOVERY_ACCEPTANCE.md](RECOVERY_ACCEPTANCE.md) records ordinary-health autonomous outcomes before and after the seeded integer fix, actual software-rendered 300-enemy/150-projectile measurements, comparable Phaser/Godot screenshots and remaining limits. Reproducible review runners do not alter production rules or save progress. No claim of all-hero balance, physical-device FPS, final artistic parity or verified production promotion is made. The authenticated dashboard resolved delayed GitHub auto-deployment through a normal main production deployment. Vercel Ready/Current and public build.json confirm `622d374e673fdb1d08e38436a8a96d51bbc70f3b`. Direct browser runtime remains constrained by cloud WebGL2 / local proxy-certificate support; the deployed files are separately verified over HTTPS and exercised locally without weakening security.

## G2.7 — Review P0 navigation and pickup work

The attached 22 October Godot review is tracked in [QA_BACKLOG.md](QA_BACKLOG.md). Reproduction found actual chasers blocked at approved covers for 27.7–29 seconds. Retained-side deterministic cover steering and two-sided edge fallback resolve the recorded cases, while original collision geometry, speeds, stationary windows and committed charge direction remain intact. A 2,048-path sweep and actual enemy regression cases pass. Distant pickups now reject by distance before scanning snapshot membership, preserving magnet protection and collection order.

The complete 31-phase local Godot suite and Node tests pass. A new controlled full-simulation/native-render profiler records percentiles and population ranges; software-rendered measurements and remaining hardware/ordinary-play acceptance are documented in the backlog. No mechanics, balance, new art or Phaser changes are included. UI/mobile findings remain open; visual owner acceptance is deferred.

## G2.8 — Canonical ten-minute schedule

Upstream GDD approval `2ef5ffa` supersedes the old clock. Reproduced boundaries failed before the change. One shared clock now coordinates five 120-second waves, Hater at 1:00, events at 2:15/4:15/6:15/8:15, legendary first/reprise/deadline at 6:00/8:00/9:55, warning at 9:30, Big Hater at 10:00, recoverable berserk at 12:00 and last-effort messaging at 14:00. Boss warning text uses an ink plate so it remains readable over the pale floor. Existing balances and saves are unchanged; Phaser remains historical and untouched.

All 32 local Godot phases and Node tests pass, and an official Web export loads with movement/pause and no browser errors. The controlled three-hero continuous fixture passes; its protection is not survival evidence. [CLOCK_COMPARISON.md](CLOCK_COMPARISON.md) and the machine-readable observations record 18 honest-health controller runs across both schedules. None reached Big Hater. Survival/progression tuning, human session time, boss viability and physical-device performance remain open; timeline correctness does not establish balance or visual acceptance.

## G3.0 — V5 audit, 23 October 2026

Audited current main `c73624d`, no open PRs, complete GDD and mandatory production plan; examined all 22 actual PDF compositions. Nineteen original assets are hash-verified; V5 standalone handoff is absent. [V5_PARITY.md](art/V5_PARITY.md) tracks 22 scenes, staged native baselines and outstanding art/device/balance gates. The separate 37-ID icon checklist records missing bytes and unperformed alpha/32px/64px QA. No gameplay or Phaser changes.

## G3.1 — V5 theme and licensed live typography

Follows integrated G3.0 PR #46. Reproduced fallback-font and cream-secondary-action mismatches, then added pinned licensed Inter instances, V5 semantic palette, physical button states, explicit focus/selected rims and reusable live UI factories. No illustrated export is fabricated; remaining component/scene work is tracked in the V5 matrix. Relevant theme/selection tests and the full 34-phase local suite pass; native rendered QA is separate from owner acceptance and physical-device performance.

## G3.2 — separate Hero Spotlight home and selection

Follows integrated PR #47. Replaces the combined raster home/hero picker with separate live, container-based PLAY/HEROES/SETTINGS navigation and three-hero selection. Reuses approved Sigma/hero/map assets; isolated V5 logo/plate remains explicitly blocked. Fixes compact resize retained width and keyboard Enter bypass, with six-viewport tests and native reference comparisons. Full 35-phase local suite passes. No combat, balance, save or Phaser changes. Next approved scope: compact gameplay HUD/wave/boss plates; isolated illustrated cards/icons remain gated by missing approved handoff exports.

## G3.3 — compact HUD, boss plates and wave/Berserk feedback

Follows integrated PR #48. Independent navy HUD plates, readiness-state styling, silhouette-aware boss placement and canonical countdown now use real state. Transition banners consume no gameplay RNG and use active time, hostile-warning priority and restart cleanup. The V5 tracker includes real HUD/boss/transition/three-Flex snapshots, with staged-fixture and missing-art limits. No gameplay numbers, navigation, camera physics, save schema or Phaser changes. Secondary overlays and balance diagnostics remain the next independent work.

## G3.4 — secondary screens and persisted master gain

Follows integrated PR #50. Compact pause, separate build inspection, return-to-pause settings, safe profile-transfer visibility, explicit STAY/QUIT and hero-led real results are implemented. Master gain is a compatible optional v2 preference, clamped/tested and debounced; gameplay and save IDs/format remain unchanged. Native desktop/compact/portrait evidence and remaining art/audio/device gates are in the V5 tracker. Full 37-phase local suite passes. Next independent work: survival source telemetry, rendered profile reporting and remaining acceptance diagnostics, while isolated art is blocked by issue #49.

## V5 acceptance checkpoint — 23 October 2026

PRs #46/#47/#48/#50/#51 integrated; 38 local validation phases pass. Fresh-boot and focused-card keyboard regressions fixed. See [V5_ACCEPTANCE_STATUS.md](V5_ACCEPTANCE_STATUS.md) for eight failed normal-health boss-reachability observations, software-render performance, staged review evidence and restart priorities. Asset issue #49 and balance issue #52 remain open. No full visual/device acceptance or gameplay-value change is implied.

## G3.6 — offer-card hierarchy

Reattached canonical PDF verified against the audit hash. Implemented reusable live rarity/icon/name/category/effect/comparison card hierarchy and compact landscape layout; preserved all existing legal offer data/order and simulation. Fixed initial wrapped-text sizing and longest-description overlaps; local 38-phase Godot validation passes. Actual desktop/compact/portrait evidence and remaining differences are in [V5_PARITY.md](art/V5_PARITY.md#g36--live-offer-card-composition). Signed illustrations remain blocked by #49; balance #52 and physical-device acceptance remain open.

## G3.7 — current signature help and upstream reconciliation

Added live GDD §7.2 Flex explanations to all three real hero cards, kept authoritative names/durations and original portraits, and removed obsolete Cool Kid Rampage copy. Compact/portrait scrolling retains fixed START/BACK; native evidence is in [V5_PARITY.md](art/V5_PARITY.md#g37--current-signature-explanations). Local targeted navigation and all 39 local validation phases passed after incorporating upstream #55/#56 (`3c963bf`).

The later [six-run strategic evidence](SURVIVAL_STRATEGIC_EVIDENCE.md) includes a Sigma victory and an Alpha boss entry. Historical avoidance failures remain valid but are not the complete current acceptance record. #52 still requires broader and human validation; #49 still blocks signed standalone illustration exports. No gameplay-value changes or owner/device acceptance are implied.

## Private Web Alpha — GDD legendary support-shield audit

Restart audited main `7fcd007`, no open PRs, current GDD/production references and #49/#52. Reproduced five GDD-expectation failures: Unbothered and My Aura support shields incorrectly inherited rarity 2.60. Restored §8.2 HP × support formulas while retaining own Cope Shield rarity scaling, support modifiers, expiry/pause and the global shield cap. All 39 local Godot phases pass; native controlled-attack captures are recorded. This is an existing-GDD implementation correction, not new balance tuning. See [WEB_ALPHA_ACCEPTANCE.md](WEB_ALPHA_ACCEPTANCE.md) for the 24 distinct release gates and exact before/after values. Historical survival data is pre-correction; rerun 451/452 and 453–456 next. Standalone art #49, full interaction audit, current WebGL2, human balance and physical-device gates remain open.

## Private Web Alpha — 18 post-correction survival observations

Merged gameplay correction #58 is verified at `a60f574cdab72b425eec93faa43321e123eb5e94` in production. Repeated all three heroes at 451/452 and added 453–456: 18 real normal-health strategic episodes, two Sigma wins, three Alpha boss losses, no Cool Kid boss entry. Five unaffected historical episodes preserve time/kills/level/healing/Flex/equipment/recovery exactly; Alpha 452 now loses at 772.30 s after the GDD shield correction. Full source-hashed data, real event completion and equipment snapshots are in [WEB_ALPHA_SURVIVAL_EVIDENCE.md](WEB_ALPHA_SURVIVAL_EVIDENCE.md). Review-only observers preserve actual HP/Aura/RNG/kills/drops; all 39 local phases pass. No balance values, artwork, production mechanics or backend were added. #52 stays open for broader/human and isolated attack-policy validation; #49 and current browser/device/performance gates remain separate.

## GDD Chad Hands late-slam correction

A controlled legal Alpha fixture reproduces two §8/§8.2 defects when the opening punch misses and the delayed second punch is the third successful activation. The current area dictionary was appended twice to a temporary list, applying the slam multiplier twice. Resolving the transformation inside the damage loop also skipped outer targets visited before the first close hit. At P=90/common, the same setup caused 65.45 damage and either zero or 65.45 to the outer target depending on array order, rather than the specified 0.40P = 36 each.

Successful activation is now determined using the unchanged eligible geometry before damage recipients are visited. Each existing delayed area is transformed once. Normal/legendary coefficients remain 0.40P / 0.60P×R, radii remain 110/140 U, and the second hit remains at 0.18 s. Shared hit memory, one proc/Aura event, pause and lifecycle remain intact. Common/legendary and reversed-order regressions fail before and pass after; all 39 local Godot phases pass. No canonical tuning values or GDD text are changed.

[Actual native controlled late-slam capture](art/evidence/web-alpha/chad_slam.jpg) uses original artwork and the real attack/HUD code. This is not a normal-health run or artistic/device acceptance. `tests/capture_review.gd -- 1280 720 OUTPUT --state=chad_slam` reproduces only that fixture. The prior 18-run data is explicitly the earlier post-shield source; repeat the same full matrix after this new gameplay correction before presenting current survival acceptance. #49/#52 and browser/human/device gates remain open.

## Current post-Chad validation checkpoint

Completed the full 18-episode 451–456 / three-hero repeat after the late-slam correction. [Current raw results](WEB_ALPHA_CHAD_SURVIVAL_RUNS.json) pin the exact PR #61 core revision/hash; [comparison](WEB_ALPHA_SURVIVAL_EVIDENCE.md#current-repeat-after-the-chad-hands-correction) preserves the prior 18 separately. All 12 ranged/melee episodes reproduce key outcomes exactly. Alpha 452 now loses at 568.40 s before boss; Alpha 455/456 still reach the boss and lose. Sigma wins 451/455; Cool Kid reaches no boss. No broader balance/human acceptance follows.

Concurrent art-only main updates `dca1a758` / `4e0a4f7` add candidate icon sources, not approved runtime art. Preflight verified all 83 manifest file hashes (40 PNG, 37 SVG, six WEBP), PNG dimensions/transparent alpha and the nine weapon / 28 passive ID mapping. Approval remains PRODUCTION_CANDIDATE, Touch Grass v2 has no matching SVG, and actual Godot 32/64-pixel icon acceptance is pending. No candidate is wired to the active UI. The available cloud browser was reopened: its visible loader again reports missing WebGL2; interactive-browser acceptance is not claimed. Its observed loader referenced `game-dca1a7586545.js`; independently fetched production HTML subsequently referenced `game-4e0a4f7eff8b` during automatic deployment.


## Candidate art resource isolation

The #60 candidate library is available for review but remains individually unapproved. An actual production-pack inspection reproduced accidental inclusion through all-resource export. A `.gdignore` exclusion and engine resource regression isolate candidates without activating them. See [candidate isolation evidence](art/CANDIDATE_ART_ISOLATION.md); rendered 32/64px and creator acceptance remain pending.


## G4.1 Clean Cut source review

All 37 canonical candidates and 83 manifest files were audited, including actual Godot SVG decoding and source composites at 32/64/256px on navy/cream. See `docs/art/CLEAN_CUT_ICON_REVIEW.md` and per-ID audit JSON. SVG font differences, narrow margins and compact identity families are recorded. Zero individual approvals or runtime promotions; the 23-passive subset and candidate export isolation remain unchanged. Next: reusable approved icon pipeline and live fallback bindings; activate only exact creator-approved hashes.


## G4.1 approved icon pipeline and safe live bindings

The source audit is integrated through #64. A separate approval ledger, immutable hashed PNG promotion, category-aware cached registry and automatic actual-PCK export guard now prepare live offer/legendary/replacement, build and HUD bindings. Eleven Python regressions and a Godot registry phase supplement the existing suite. All 40 actual before/after fallback captures are pixel-identical; compact viewport one-pixel rounding is recorded. See `docs/art/APPROVED_ICON_PIPELINE.md`. Counts remain 37 audited, 0 creator-approved, 0 promoted, 0 illustrated items accepted in live UI. Creator decisions, approved-icon visual/performance evidence and device/browser gates remain pending; gameplay/23-passive scope are unchanged.

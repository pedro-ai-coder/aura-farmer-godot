# Godot QA backlog — 22 October 2026

Source: attached `Aura_Farmer_Godot_Review_2026-10-22.md`. Authority remains the canonical GDD and its approved art references. This backlog does not approve new mechanics, handedness settings, balance changes or replacement artwork. Phaser remains unchanged.

| Finding | Status | Reproduction / next acceptance step |
| --- | --- | --- |
| AF-01: gameplay fluidity | Partial correction; hardware acceptance open | Reproduced expensive distant-pickup membership scans. Distance rejection now precedes membership lookup, preserving magnet snapshot protection. Full simulation/render benchmark added; ordinary canonical-clock desktop and physical Android profiling still required. |
| AF-02: enemy navigation | Reproduced and corrected locally | Actual goblin, NPC and Beta chasers remained blocked at cover for 27.7–29 seconds. Deterministic retained-side cover waypoints and two-sided edge fallback now reach the target. Collision geometry, movement speeds, RNG and locked charge direction are unchanged. |
| AF-03: upgrade cards | Partial correction; visual acceptance open | Reproduced a failing runtime assertion at 915×412: third normal choice wrapped to a second row. Three columns now depend on available width rather than window height; all three choices share one landscape row. Narrow portrait retains internal scrolling and explicit confirmation. Exact illustrated assets, text density and visual acceptance remain open. |
| AF-04: secondary panels | Partial correction; visual acceptance open | Pause now presents three weapon and five passive slots, including empty capacity, existing catalog symbols, actual names, rarity borders and levels. Board uses internal scrolling with settings below on narrow/short screens; equipment and action bounds are tested at six sizes. Exact approved font and illustrated equipment assets still require verified references; no new artwork was added. |
| AF-05: full-playfield floating joystick and size | **Approved GDD change; implementation and device acceptance outstanding** | Creator-approved Annex C.1 revision (23 October 2026) replaces left-48%-only activation with eligible touch-down anywhere on visible unobstructed gameplay terrain, regardless of left/right placement. Increase reference outer radius ~57→80, thumb radius ~25→35 and movement saturation ~85→119 (responsive to safe areas); no change to hero movement speed. Exclude actual interactive Flex/Pause/menu/card/scroll/control hit areas, preserving separate multitouch action input and no simultaneous UI/joystick activation. Replace obsolete left-only tests; verify pointer ownership, modal/pause/focus/orientation cancellation, landscape/portrait, real mobile Web and physical Android/iOS separately. No separate handedness toggle is required. |
| AF-06: combat readability/mobile | Open | Review HUD, Flex, pickups and landscape layouts after the P0 corrections. Physical Android/iOS acceptance remains outstanding. |

## P0 reproduction and validation

Baseline: `2f3519a014a05405807a3089c85ade30e2d09e17`. Actual enemy integration cases include both covers, mirrored approaches and concave floor corners. Before correction, three cover cases failed; afterwards all reached contact without a two-second blocked interval. A separate geometric sweep tested 2,048 cover paths over four body radii without reproducing a blocked path. Intentional terminal holds, ranged distance bands, boss telegraphs/stagger, recovery windows and straight committed charges have regression coverage.

All 31 Godot validation phases and Node platform tests passed locally on official Godot 4.7.2. These are automated functional results, not visual owner acceptance.

## Performance evidence and limits

`tests/review_simulation_profile.gd` runs actual enemy AI, weapons, projectiles, collisions and pickup logic, optionally with rendering. It reports warm P50/P95/P99, cold maxima, long-frame counts and observed population ranges. The controlled fixture protects the player, suppresses XP progression and preserves enemy population; it is not an ordinary survival or balance test. Its 300-enemy case exceeds the normal 100-enemy solo cap.

Native Compatibility rendering used Mesa llvmpipe under Xvfb at 1280×720, with 240 simulation frames per fixture and 40 warm-up frames excluded. CPU identification is unavailable in the sandbox. Nominal player projectile counts are maintained before and after simulation; enemy attacks may add hostile projectiles. Both runs retain 200 distant XP pickups.

| Enemies / player projectiles | Before mean frame / P95 (ms) | After mean frame / P95 (ms) | Before / after pickup mean (µs) |
| --- | --- | --- | --- |
| 30 / 15 | 24.67 / 35.04 | 21.33 / 32.41 | 1328 / 82 |
| 100 / 50 | 27.46 / 32.78 | 26.18 / 31.19 | 1174 / 91 |
| 300 / 150 | 64.67 / 82.23 | 60.96 / 71.67 | 1173 / 80 |

The order-of-conditions change removes distant membership scans; the isolated headless 30-enemy fixture reduced pickup CPU from 1194 to 63 µs per step. Whole-frame timings include shared-host/software-renderer variability and are observations, not guaranteed speedups or 60-FPS acceptance. The stress fixture remains slow. Projectile processing is a measured follow-up candidate; preserve hit/death/proc ordering before optimizing it.

Reproduce with official Godot:

```sh
godot --headless --path . --script res://tests/test_enemy_navigation.gd
godot --headless --path . --script res://tests/review_navigation_sweep.gd
godot --headless --path . --script res://tests/review_simulation_profile.gd -- /absolute/path/profile.json
# Run the last command without --headless for simulation + native rendering.
```

For AF-01 closure, record ordinary unprotected play on desktop and physical Android using the newly approved ten-minute schedule: device/renderer, viewport, warm/cold state, full progression through Big Hater and recoverable berserk, frame percentiles/long frames and actual entity/projectile/effect counts. Software rendering and touch emulation cannot replace those checks.

## Concurrent canonical update

During QA, upstream main advanced to `2ef5ffacfe57e5ed2c7e9cea92facb412fc0b9ef`: five 120-second waves, Big Hater at 600 s, recoverable berserk after 120 s of boss combat. The following clock iteration implements the coherent event/legendary/boss migration; exact boundaries and warnings have independent regression coverage. Eighteen ordinary-health controller runs are recorded in [CLOCK_COMPARISON.md](CLOCK_COMPARISON.md); none reached Big Hater, so balance acceptance remains open. The above baseline measurements are explicitly from the historical 15-minute implementation. Flex redesigns and prototype concepts do not authorize new default mechanics.

## Signature Flex 2.0 follow-up

GDD `f2ec242` §7.2 is now implemented on the signature Flex branch with deterministic regression coverage and instrumented ordinary-health observations. See [FLEX_V2_VALIDATION.md](FLEX_V2_VALIDATION.md). Production readiness remains unaccepted: none of the three seed-451 avoidance-controller runs reached Big Hater; dedicated signature art/readability and physical-device acceptance remain open. Do not equate functional parity with balance acceptance.

## Hero Spotlight V5 production follow-up

Current visual execution and isolated export blockers are tracked in [art/V5_PARITY.md](art/V5_PARITY.md). Production target is §26; existing palette-only UI is not V5 acceptance. No handoff ZIP was supplied; 37 icon approvals and standalone logo/clean plate remain blocked. Continue theme, live navigation and responsive components independently.

G3.2 separates home and hero selection and preserves explicit START/focus/safe viewport behavior. Existing approved portraits are retained; text heading does not claim completion of the missing illustrated logo. Compact selection can scroll cards while its actions remain pinned. See the V5 tracker for actual captures and remaining card/HUD/secondary-screen gaps.

G3.4 splits compact Pause from Build/Settings, fixes in-run Settings return and protects active runs from profile-transfer navigation. Real result values, hero portraits, master gain and STAY/QUIT are tested; see V5 captures. The 3+5 inspector remains text/glyph-based pending signed icon exports. Fine-grained settings tabs/audio buses, device/browser tests and final artistic acceptance are not complete.

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

# Godot QA backlog — 22 October 2026

Source: attached `Aura_Farmer_Godot_Review_2026-10-22.md`. Authority remains the canonical GDD and its approved art references. This backlog does not approve new mechanics, handedness settings, balance changes or replacement artwork. Phaser remains unchanged.

| Finding | Status | Reproduction / next acceptance step |
| --- | --- | --- |
| AF-01: gameplay fluidity | Partial correction; hardware acceptance open | Reproduced expensive distant-pickup membership scans. Distance rejection now precedes membership lookup, preserving magnet snapshot protection. Full simulation/render benchmark added; ordinary canonical-clock desktop and physical Android profiling still required. |
| AF-02: enemy navigation | Reproduced and corrected locally | Actual goblin, NPC and Beta chasers remained blocked at cover for 27.7–29 seconds. Deterministic retained-side cover waypoints and two-sided edge fallback now reach the target. Collision geometry, movement speeds, RNG and locked charge direction are unchanged. |
| AF-03: upgrade cards | Partial correction; visual acceptance open | Reproduced a failing runtime assertion at 915×412: third normal choice wrapped to a second row. Three columns now depend on available width rather than window height; all three choices share one landscape row. Narrow portrait retains internal scrolling and explicit confirmation. Exact illustrated assets, text density and visual acceptance remain open. |
| AF-04: secondary panels | Partial correction; visual acceptance open | Pause now presents three weapon and five passive slots, including empty capacity, existing catalog symbols, actual names, rarity borders and levels. Board uses internal scrolling with settings below on narrow/short screens; equipment and action bounds are tested at six sizes. Exact approved font and illustrated equipment assets still require verified references; no new artwork was added. |
| AF-05: joystick handedness | Design decision outstanding | Canonical left 48% floating joystick remains authoritative. Right-handed mode is not approved by this review. Continue testing ownership, release, safe areas and focus loss. |
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

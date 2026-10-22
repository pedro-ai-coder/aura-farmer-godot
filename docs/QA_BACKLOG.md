# Godot QA backlog — 22 October 2026

Source: attached `Aura_Farmer_Godot_Review_2026-10-22.md`. Authority remains the canonical GDD and its approved art references. This backlog does not approve new mechanics, handedness settings, balance changes or replacement artwork. Phaser remains unchanged.

| Finding | Status | Reproduction / next acceptance step |
| --- | --- | --- |
| AF-01: gameplay fluidity | Partial correction; hardware acceptance open | Reproduced expensive distant-pickup membership scans. Distance rejection now precedes membership lookup, preserving magnet snapshot protection. Full simulation/render benchmark added; ordinary canonical-clock desktop and physical Android profiling still required. |
| AF-02: enemy navigation | Reproduced and corrected locally | Actual goblin, NPC and Beta chasers remained blocked at cover for 27.7–29 seconds. Deterministic retained-side cover waypoints and two-sided edge fallback now reach the target. Collision geometry, movement speeds, RNG and locked charge direction are unchanged. |
| AF-03: upgrade cards | Open | Review baseline captured. At 915×412 the implementation uses two columns with vertical scrolling, rather than horizontal scrolling. Improve density, rarity hierarchy, current-to-next information and focus/touch legibility within approved art. |
| AF-04: secondary panels | Open | Pause build currently uses text rows. Implement the approved three-weapon/five-passive equipment presentation and check pause/options/results at short and narrow sizes. Exact approved font and illustrated equipment assets must be verified before any replacement; no new artwork is authorized. |
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

During QA, upstream main advanced to `2ef5ffacfe57e5ed2c7e9cea92facb412fc0b9ef`: five 120-second waves, Big Hater at 600 s, recoverable berserk after 120 s of boss combat. This P0 patch preserves that GDD update but does not yet implement its coherent event/legendary timing migration. Schedule implementation and honest-health comparisons are the next approved gameplay task. The above baseline measurements are explicitly from the historical 15-minute implementation. Flex redesigns and prototype concepts do not authorize new default mechanics.

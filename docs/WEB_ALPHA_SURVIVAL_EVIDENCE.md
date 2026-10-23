# Post-correction ordinary-health survival evidence

23 October 2026. Production gameplay revision: `a60f574cdab72b425eec93faa43321e123eb5e94` (PR #58). The measured solo_run.gd SHA-256 is verified against that exact Git object. The [raw 18 results](WEB_ALPHA_SURVIVAL_RUNS.json) retain core/review/policy/asset-manifest hashes, source damage, actual legal equipment, recovery, Flex contribution, wave snapshots and event spawn/defeat transitions. Every valid episode terminated in victory or defeat; none is a timeout or unfinished loop reported as a loss.

## Method and provenance

Reproduced seeds 451/452 for all starters and added 453–456, using the existing opt-in strategic policy and its unchanged legal upgrade decisions. No invulnerability, HP/XP/Aura grants, time jumps, deleted enemies or forced boss kills. The runner calls the real production _process(0.1), which uses fixed simulation substeps; profile writes are disabled. These are headless deterministic input-policy experiments, not human runs or browser/FPS acceptance.

Review-only instrumentation adds actual equipment to wave snapshots and records event/boss spawn and actual defeat once. Its regression compares HP, Aura, RNG, kills and drops with an uninstrumented production instance and rejects duplicate completion callbacks. Ordinary runs do not use the controlled fatal-damage unit fixture. Defeat counts below exclude Big Hater; an event merely retiring at 10:00 is not a kill.

Reproduce each episode with `godot --headless --path . --script res://tests/review_unprotected_run.gd -- HERO_INDEX SEED --strategic`, indices 0/1/2 and seeds 451–456. Use official Godot 4.7.2 and hash-verified assets. The unchanged old avoidance and aimed-Flex modes remain available. The same initial seed does not guarantee identical enemy timelines between different input policies.

## All outcomes

| Seed | Hero | Active seconds | Outcome | Boss entry | Level | Safe Spot uses | Event bosses defeated |
| --- | --- | ---: | --- | --- | ---: | ---: | ---: |
| 451 | sigma | 674.72 | won | Yes | 25 | 4 | 4 |
| 451 | cool-kid | 569.95 | lost | No | 24 | 3 | 3 |
| 451 | alpha | 312.23 | lost | No | 15 | 0 | 0 |
| 452 | sigma | 148.42 | lost | No | 8 | 0 | 0 |
| 452 | cool-kid | 404.90 | lost | No | 17 | 0 | 1 |
| 452 | alpha | 772.30 | lost | Yes | 24 | 5 | 3 |
| 453 | sigma | 506.95 | lost | No | 22 | 0 | 3 |
| 453 | cool-kid | 519.62 | lost | No | 22 | 2 | 3 |
| 453 | alpha | 504.55 | lost | No | 21 | 1 | 3 |
| 454 | sigma | 529.78 | lost | No | 23 | 1 | 3 |
| 454 | cool-kid | 517.73 | lost | No | 22 | 3 | 3 |
| 454 | alpha | 337.55 | lost | No | 15 | 1 | 0 |
| 455 | sigma | 694.38 | won | Yes | 25 | 1 | 4 |
| 455 | cool-kid | 507.95 | lost | No | 22 | 0 | 3 |
| 455 | alpha | 786.20 | lost | Yes | 24 | 3 | 3 |
| 456 | sigma | 527.78 | lost | No | 24 | 2 | 4 |
| 456 | cool-kid | 300.67 | lost | No | 13 | 1 | 0 |
| 456 | alpha | 849.35 | lost | Yes | 21 | 4 | 1 |

## Comparison with the historical six-run strategic record

Five unaffected 451/452 episodes exactly preserve survival time, kills, level, healing, Flex count, equipment and recovery. Alpha 452 changes after removing excess legendary shield scaling: boss entry at 600.02 s with **136.72 HP**, defeat at **772.30 s** instead of 810.82 s, with **962.13 HP healed** and five actual Safe Spot uses. It still enters recoverable Berserk. This is a new deterministic outcome after a verified GDD correction, not permission to restore the erroneous shielding or change canonical balance values. All historical files remain intact and explicitly pre-correction.

## Interpretation and next experiments

Across the 18 episodes, Sigma has two actual victories (451, 455); Alpha enters the boss in 452/455/456 and loses during the encounter; Cool Kid reaches none. This sample demonstrates legal wins on the approved clock but does not establish human win rates, all-hero fairness or release readiness. The 12 additional-seed episodes include all failures, not only the Sigma 455 win.

- **sigma:** active-time median 528.78 s (not human session time); 6 distinct terminal equipment configurations under one fixed upgrade policy. Largest aggregate HP-loss sources: ratio-ram/contact 431.60, fanum-leech/direct 430.62, doomscroll-prime/direct 317.11.
- **cool-kid:** active-time median 512.84 s (not human session time); 6 distinct terminal equipment configurations under one fixed upgrade policy. Largest aggregate HP-loss sources: reply-guy/direct 855.00, fanum-leech/direct 555.60, ratio-ram/contact 395.87.
- **alpha:** active-time median 638.42 s (not human session time); 6 distinct terminal equipment configurations under one fixed upgrade policy. Largest aggregate HP-loss sources: boss/direct 654.93, reply-guy/direct 597.37, fanum-leech/direct 528.29.

Boss reachability, build variety from seeded offers and survival remain strongly policy/seed-dependent. Alternative build-selection policies and human input have not been measured here. Next isolate Cool Kid's Reply Guy / Doomscroll pressure, Alpha's boss pattern response and recovery access, and Sigma's early seed failures before proposing any numerical tuning. Re-run specific affected seeds after future gameplay fixes, retaining exact source revisions. Issue #52 remains open.

The full 39-phase local Godot validation suite passes with the observer regression. Actual browser WebGL2, reference hardware performance, human balance and physical Android/iOS remain independent gates. Art availability is unchanged (#49); no gameplay backend or new production mechanic is introduced.

# Issue #52 — Strategic normal-health survival evidence

**Evidence date:** 23 October 2026.  
**Godot source tested:** PR #56 candidate based on merged PR #55 (`800b75d`); no gameplay-stat, drop, clock or RNG code changed from canonical `main`.  
**First seed reproduction:** [GitHub Actions run 39995707283](https://github.com/pedro-ai-coder/aura-farmer-godot/actions/runs/39995707283), job `ordinary-health-review`, official Godot 4.7.2 with the pinned approved Phaser assets. Three completed `UNPROTECTED RESULT` JSON records, seed 451, `--strategic`. Historical baseline: [V5_SURVIVAL_RUNS.json](V5_SURVIVAL_RUNS.json), same hero/seed with `avoidance`. The baseline controller remains intact.

## Same-seed comparison: seed 451

| Hero | Baseline survival / outcome | Strategic survival / outcome | Change in active time | Strategic level | Strategic kills | Strategic collected Snacks / Magnets | Strategic Safe Spot uses |
| --- | --- | --- | ---: | ---: | ---: | --- | ---: |
| Sigma | 431.67 s / defeat before boss | **674.72 s / victory** | +243.05 s | 25 | 738 | 38 / 12 | 4 |
| Cool Kid | 303.62 s / defeat before boss | **569.95 s / defeat** | +266.33 s | 24 | 682 | 46 / 15 | 3 |
| Alpha Chad | 446.32 s / defeat before boss | **312.23 s / defeat** | **−134.08 s** | 15 | 337 | 15 / 3 | 0 |

**Sigma:** entered Big Hater at 600.02 s with 145.39 HP and level 25; completed a genuine normal-health automated victory at 674.72 s (11:14.72 active), with 107.59 HP remaining. Logged healing was 599.72 HP, 11 Flex activations, 312.65 secondary Flex damage and four real Safe Spot heals. This is a concrete legal-build boss win, **not** a human win rate, 60-FPS acceptance or cross-platform certification.

**Cool Kid:** advanced to 569.95 s (9:30), level 24, but lost to Doomscroll Prime before boss entry. Logged 769.94 HP healing, 7 Flex activations, 568.47 secondary Flex damage, three Safe Spot heals. Significant losses remained from Reply Guy (**324.90 HP, direct**), Doomscroll Prime (**245.20 HP, direct**) and its hazards (**44.23 HP**). Recovery opportunities and real directional Flex damage materially improved over the old controller, but ordinary boss viability is still unknown.

**Alpha Chad:** survived only 312.23 s (5:12), level 15, versus 446.32 s for the prior avoidance controller. Recovery route did **not** reach the Safe Spot; healing was just 137.92 HP. Damage was dominated by Reply Guy and other close-range threats. Alpha still dealt 1,704.10 secondary Flex damage, showing that Flex damage alone does not ensure survival. This strategic policy is demonstrably **not universally better**, and Alpha's positioning/recovery strategy requires separate experiments before numerical balance changes.

## Independent replication: seed 452

**Evidence:** [GitHub Actions run 39996311108](https://github.com/pedro-ai-coder/aura-farmer-godot/actions/runs/39996311108), job `ordinary-health-review`; the same approved gameplay state and review-only strategic policy with seed **452**. Raw records for **both seeds and all six outcomes** are committed in [SURVIVAL_STRATEGIC_RUNS.json](SURVIVAL_STRATEGIC_RUNS.json), with full damage sources, boss-entry state, legal equipment, recovery counters and Flex contribution.

| Hero | Seed-452 baseline / outcome | Seed-452 strategic / outcome | Change in active time | Strategic level | Reached Big Hater? | Strategic healing / Safe Spot |
| --- | --- | --- | ---: | ---: | --- | --- |
| Sigma | 282.10 s / defeat | **148.42 s / defeat** | **−133.68 s** | 8 | No | 41.04 HP / 0 uses |
| Cool Kid | 362.38 s / defeat | **404.90 s / defeat** | +42.52 s | 17 | No | 190.86 HP / 0 uses |
| Alpha Chad | 450.02 s / defeat | **810.82 s / defeat** | **+360.80 s** | 24 | **Yes** | 881.08 HP / **5 uses** |

- **Sigma:** Died in wave 2 after heavy Reply Guy direct damage (54 HP) and Ratio Ram contact damage (46 HP). One seed victory and one early seed defeat prove that the new review policy is sensitive to event positioning; do not treat the first win as a generally safe difficulty curve.
- **Cool Kid:** Survived 42.52 s longer than the matched old controller, yet still fell in wave 4. Reply Guy direct attacks (119.7 HP) and ranged Hater shots (67.43 HP) dominate its seed-452 damage record; recovery and aiming improvements alone do not solve dangerous projectile/event pressure.
- **Alpha Chad:** Reached Big Hater at the canonical **600.02 s** with **143.02 HP** and level 24, survived through the recoverable **720-second Berserk**, and died at **810.82 s (13:30.82 active)**. Big Hater dealt 247.18 direct HP damage in eight logged hits; 881.08 HP was healed over the run, including five real Safe Spot uses. Reaching the boss does **not** prove the boss is consistently killable on Alpha's legal builds.

**Combined six-run observation:** one actual victory (Sigma seed 451), two boss entries (Sigma 451, Alpha 452), four defeats before boss and one defeat during boss. Cool Kid reached neither boss in these two scripted-controller seeds. All six runs completed normally in CI; no timeout was mistaken for a defeat.

## Interpretation boundaries

- **All three trials used approved gameplay mechanics**, no forced kills, no unearned heals, no time jumps, no invulnerability and no manual boss grants. Only the AI-controlled inputs and routes changed; the source GDD combat formulas did not.
- The same RNG **seed** is necessary for reproducibility, but different movement, kills and timing can consume gameplay RNG along different legal paths. These are valid same-initial-seed *strategy experiments*, not paired identical enemy timelines.
- Six scripted episodes across two seeds are not a statistically meaningful hero win-rate sample. At least another independent seed, alternative builds and **human played runs** are needed to decide whether any changes to approved HP, XP, attack or spawn values are justified.
- The results **refute the categorical claim** that the 10-minute clock makes the solo game mechanically unwinnable: Sigma won under the approved schedule, while the other outcomes show substantial seed/controller sensitivity. It does **not** demonstrate that the difficulty is fair for the other two heroes or that a normal human can reliably win.
- Rendering, cross-platform input, WebGL2 and physical device FPS were **not** measured by these headless Godot observations. The V5 standalone art blocker in Issue #49 is independent.

## Recommended next comparisons

1. The seed-452 replication is complete. Continue to **seeds 453–456**, record successes and all failures, and compare with human-controlled runs before making hero-balance conclusions.
2. Improve **Alpha-specific recovery routing** and close-range threat evasion in a review-controller experiment, *without* changing Alpha's GDD numbers; measure the resulting damage-source shift.
3. For Cool Kid, separately measure Reply Guy/Doomscroll Prime line-of-sight, warning and projectile dodge response. Compare a safe positioning policy to an aggressive Flex policy before any buff proposals.
4. Compare legal build choices and boss damage-per-minute in ordinary-health encounters; make no hidden level/item grant in acceptance runs.
5. When a numeric adjustment is genuinely warranted, prepare a specific GDD proposal for owner approval **before** changing production combat.

To rerun, use the merged [controller methodology](SURVIVAL_CONTROLLER_REVIEW.md) or the bounded [Survival Strategy Telemetry workflow](../.github/workflows/survival-telemetry.yml). Issue #52 remains open until all hero and human acceptance gates are met.

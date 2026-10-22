# Canonical clock comparison — automated normal-health controller

GDD §25.1 approves the schedule, not new balance values. Reproduction before changes found wave 1 still active at 120 seconds, no legendary modal at 360 seconds and no Big Hater at 600 seconds. `test_run_clock.gd` now independently checks exact wave/event/Hater/legendary/boss/berserk boundaries and warnings.

The same `review_unprotected_run.gd` controller ran seeds 451, 454 and 457 for Sigma, Cool Kid and Alpha under the historical 15-minute regime and new 10-minute regime. Both include the P0 navigation correction from PR #39. There is no invulnerability, clock jump, XP grant, damage grant or final-hit injection in these samples; only profile I/O is isolated. The controller chooses upgrades, moves, aims and activates Flex automatically. These are bot outcomes, not human balance acceptance.

| Regime | Hero | Median active seconds / P90 | Median level | Boss entries / wins | Deaths by wave |
| --- | --- | --- | --- | --- | --- |
| 15-minute | sigma | 749.0 / 779.1 | 25 | 0 / 0 | W5: 3 |
| 15-minute | cool-kid | 338.2 / 400.5 | 14 | 0 / 0 | W2: 2, W3: 1 |
| 15-minute | alpha | 413.8 / 584.2 | 16 | 0 / 0 | W2: 1, W3: 1, W4: 1 |
| 10-minute | sigma | 415.4 / 459.2 | 20 | 0 / 0 | W3: 1, W4: 2 |
| 10-minute | cool-kid | 251.0 / 303.6 | 13 | 0 / 0 | W2: 1, W3: 2 |
| 10-minute | alpha | 351.9 / 433.0 | 16 | 0 / 0 | W3: 2, W4: 1 |

P90 uses nearest rank on three samples per hero/regime; it is descriptive, not a reliable population estimate. Every sample died before Big Hater. These results identify an open survival/progression tuning problem; they do not establish that the clock migration caused every difference or authorize compensating buffs. Identical seed labels do not imply identical encounters because wave timing changes spawn legality and RNG consumption.

Protected continuous integration separately exercises legal offers, all five waves, level caps, boss and terminal resolution. Its protection and optional final hit make it unsuitable for boss viability/win-rate claims. Boss-entry builds and honest-health boss win rate cannot be evaluated from zero entries. Real session median/P90 including human choice time, meaningful-choice quality, level-25 reachability, rendered FPS and physical-device caps remain unverified.

No HP, damage, XP formula, reward size, drop chance, Aura/Flex value, rarity weight, density multiplier, inventory cap or save schema has been changed. Any tuning follows a separate measured GDD decision. Phaser remains the untouched historical reference.

## Per-run observations

| Regime | Hero / seed | Active seconds | Level / choices / Flexes | Snacks / magnets / station uses |
| --- | --- | --- | --- | --- |
| old | sigma / 451 | 743.5 | 25 / 25 / 12 | 42 / 16 / 1 |
| old | sigma / 454 | 779.1 | 25 / 25 / 13 | 43 / 20 / 2 |
| old | sigma / 457 | 749.0 | 25 / 25 / 12 | 53 / 21 / 3 |
| old | cool-kid / 451 | 338.2 | 14 / 13 / 4 | 15 / 6 / 1 |
| old | cool-kid / 454 | 310.3 | 13 / 12 / 3 | 13 / 5 / 1 |
| old | cool-kid / 457 | 400.5 | 16 / 15 / 4 | 14 / 8 / 2 |
| old | alpha / 451 | 584.2 | 21 / 21 / 7 | 35 / 8 / 1 |
| old | alpha / 454 | 278.0 | 12 / 11 / 2 | 10 / 6 / 1 |
| old | alpha / 457 | 413.8 | 16 / 15 / 4 | 17 / 6 / 1 |
| new | sigma / 451 | 415.4 | 20 / 20 / 6 | 26 / 7 / 2 |
| new | sigma / 454 | 459.2 | 21 / 21 / 8 | 21 / 15 / 0 |
| new | sigma / 457 | 286.2 | 14 / 13 / 4 | 9 / 7 / 1 |
| new | cool-kid / 451 | 303.6 | 15 / 14 / 3 | 16 / 6 / 1 |
| new | cool-kid / 454 | 251.0 | 13 / 12 / 3 | 10 / 2 / 1 |
| new | cool-kid / 457 | 229.8 | 12 / 11 / 2 | 11 / 5 / 1 |
| new | alpha / 451 | 351.9 | 16 / 15 / 3 | 19 / 5 / 2 |
| new | alpha / 454 | 350.4 | 16 / 15 / 4 | 9 / 4 / 1 |
| new | alpha / 457 | 433.0 | 19 / 19 / 5 | 20 / 10 / 1 |

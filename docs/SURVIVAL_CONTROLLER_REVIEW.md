# Issue #52 — Deterministic strategic-controller acceptance experiment

**Scope:** Testing/diagnostics only. The baseline live game, canonical GDD, Phaser, hero statistics, approved drops and boss behavior are unchanged. This experiment does **not** establish human win rates or new balance settings.

## Why another controller is needed

The historical `tests/review_unprotected_run.gd` controller uses a fixed oval patrol, only considers a Snack/Magnet once the *weighted* distance is below 65 U (effectively **325 U for injured-player Snacks** and about **217 U for Magnets** under its original multipliers), enters Safe Spot recovery at <40% HP, and generally auto-fires Flex without checking Cool Kid's real close-range cone. Its ranged mouse aim prefers visible bosses. Eight recorded seed-451/452 observations in `docs/V5_SURVIVAL_RUNS.json` lost before the 600-second Big Hater start; one earlier 15-minute baseline with different conditions did reach a boss. These are **controller-dependent observations**, not definitive evidence that the GDD-approved damage, healing or XP must change.

This PR adds a **second, opt-in controller** while retaining the old baseline path byte-for-byte in its movement, aim and upgrade decisions:

- Longer-distance Snack pursuit when hurt and Magnet pursuit only when real XP crystals exist on the ground. Respect actual world/covers, target availability and pickup radius; no collection directly from the controller.
- Safe Spot as an explicit, cooldown-aware goal, with an in-radius hold preference to complete the existing two-second charge. Real active simulation still determines whether attackers force the controller to evade.
- Candidate movement directions scored against immediate enemy danger, projected hostile-shot trajectories and imminent hazards, without changing enemies, hitboxes or attack rules.
- Mouse aim toward legal nearby targets and timing-aware Flex activation: Sigma requires a legal locked enemy; Cool Kid attempts close-range keyboard cones; Alpha uses slams/shield near a threat.
- Count controller intention frames per destination. Actual Snack/Magnet pickups, healing, XP, player damage, Flex contribution, event pressure and eventual boss result remain the real `solo_run.gd` telemetry.
- No RNG calls, damage/HP/resource grants, deleted enemies, impossible navigation, time skips, forced wins or edits to normal game logic.

## How to reproduce

Requires Godot **4.7.2** with the approved Phaser art installed through `python3 scripts/sync_approved_assets.py`, and imported textures. Run `bash scripts/validate.sh` first.

```sh
# Historical baseline (unchanged); hero index 0 Sigma, 1 Cool Kid, 2 Alpha Chad.
godot --headless --path . --script res://tests/review_unprotected_run.gd -- 0 451

# Historical optional Cool Kid aimed-Flex baseline.
godot --headless --path . --script res://tests/review_unprotected_run.gd -- 1 451 --aim-flex

# Improved, still ordinary-health deterministic diagnostic controller.
godot --headless --path . --script res://tests/review_unprotected_run.gd -- 0 451 --strategic
godot --headless --path . --script res://tests/review_unprotected_run.gd -- 1 451 --strategic
godot --headless --path . --script res://tests/review_unprotected_run.gd -- 2 451 --strategic

# Repeat with independent seed 452, compare all three heroes and record outputs.
godot --headless --path . --script res://tests/review_unprotected_run.gd -- 0 452 --strategic
```

The runner emits one machine-readable `UNPROTECTED RESULT` JSON line per hero. Compare the **same hero/seed** and baseline/strategic policy, including `seconds`, `mode`, `boss`, `damage_sources`, `waves`, `level`, `xp_collected`, `recovery`, `station_uses`, `signature_metrics`, legal equipment and `goal_frames`. It is not valid to compare different hero/seed configurations as proof of a damage bug.

`tests/test_survival_review_policy.gd` is part of the standard CI validation and verifies longer-range recovery targeting, full-health avoidance, station cooldown/charging behavior, close-range Flex readiness, and absence of HP/Aura/RNG/state mutation. **The tests do not claim a successful full run.**

## Acceptance and follow-up

1. Verify baseline mode reproduces recorded values for seeds 451/452 (no gameplay code changed by this PR).
2. Produce multiple independent ordinary-health strategic runs without built-in cheat mechanics, recording all victories and losses. Confirm controller behavior does not strand the player against fixed covers.
3. Investigate which incoming damage sources dominate across policies, whether recovery can be reached *safely*, and whether Cool Kid's earned secondary combo hits translate into survival. Controller improvement alone is not a game-balance change.
4. Only after measuring improvement and human playtests, propose explicit GDD balance adjustments if needed, with new tests and creator authorization.
5. Keep browser WebGL2, real Android/iOS and rendered performance/visual acceptance as **separate** unverified gates. A headless, accelerated scripted run is never a human gameplay certification.

This workstream is independent of the missing approved V5 standalone art exports tracked in Issue #49.

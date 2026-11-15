# Tests and QA fixtures

**Context tier:** standard. **Scope:** `tests/`.

## Purpose

Headless Godot contract/smoke tests, Python checks, Node.js Web adapter tests and optional QA/performance fixtures. A green check, a historical report or a generated image does not approve design, art or release.

## Key files

- `./test_playable_slice.gd` — menu, hero selection and basic playable integration smoke.
- `./test_phaser_rng.gd` — seeded RNG and offer/enemy parity.
- `./test_animation_fluency.gd` — actual blocked-movement/release regression, single-cap body selection and lazy historical texture loading.
- `./test_profile_store.gd` — profile persistence contract.
- `./test_web_platform.cjs` — browser adapter assertions.
- `./test_performance_web.cjs` — Web diagnostic assertions.
- `./frame_pacing/README.md` — documented frame pacing fixture and device-test limitations.
- `./test_pixel_vixen_cpk_art_gate.gd` — targeted art integration regression.
- `./test_approved_individual_hero_sheets.gd` — six full-atlas resource routes, 384 transparent cells, cached textures and exclusion of the rejected Pixel Vixen derivative; assertions updated for v2, not executed for this delivery at creator request.
- `./frame_pacing/MAIN_BASELINE_PROVENANCE.md` — independently measured unchanged-main Windows simulation control; historical fixture is preserved rather than silently regenerated.

## Conventions

Choose the smallest targeted regression first. `scripts/validate.sh` orchestrates broader checks; inspect its dependencies and side effects before execution. Distinguish human gameplay, automated normal runs, synthetic QA scenarios and performance fixtures. Do not load large evidence directories or recordings by default.

Some historical tests and prose retain superseded assumptions. If they conflict with GDD V3 and recorded creator decisions, report the discrepancy; do not silently promote a test fixture into canon. Record source SHA, GDD version, scenario type, seed, command, platform and actual pass/fail results.

## Source-defined examples (not run here)

```sh
godot --headless --path . --script res://tests/test_phaser_rng.gd
godot --headless --path . --script res://tests/test_playable_slice.gd
node tests/test_web_platform.cjs
node tests/test_performance_web.cjs
```

Related: [scripts](../scripts/CONTEXT.md), [scenes](../scenes/CONTEXT.md), [Web](../web/CONTEXT.md).

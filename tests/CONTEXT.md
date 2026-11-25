# Tests and QA fixtures

**Context tier:** standard. **Scope:** `tests/`.

## Purpose

Headless Godot contract/smoke tests, Python checks, Node.js Web adapter tests and optional QA/performance fixtures. A green check, a historical report or a generated image does not approve design, art or release.

## Key files

- `./test_neon_menu_journey.gd` � isolated eleven-menu/six-viewport contrast, action-label fit, touch, Settings header, save editor, real held card input, simulation/profile isolation and live reduced-motion cancellation; optional native screenshots.
- `./test_playable_slice.gd` — menu, hero selection and basic playable integration smoke.
- `./first_playable/test_factory_routes.gd` checks factory cover stops, line of sight and pursuit. `./first_playable/review_factory.gd` captures synthetic stills, comparative metrics and an automated ordinary opening run.
- `./test_cpk_design_system.gd` / `./cpk_design_gallery.gd` — shared Theme contrast/state/focus/touch checks and native component review capture.
- `./test_signal_breaker_garage.gd` — isolated actual Garage, six identities/three kits, six viewports, real mouse/key/touch, menu RNG isolation and existing Solo/Settings return.
- `./test_cpk_branding.gd` — visible title/PWA/HTML identity with unchanged native profile directory and legacy browser keys.
- `./test_phaser_rng.gd` — seeded RNG and offer/enemy parity.
- `./no_u/` covers No U gameplay parity, expiry, draw priority and review lifecycle.
- `./six_to_seven/` verifies ordinary/V2 and V2/V3 gameplay parity, stages isolated review builds, and captures matched real gameplay and frame timings.
- `./passive_vfx_lab/` provides side-by-side synthetic replays, QA Recorder traces, native captures and performance checks for the proposed Six to Seven effect.
- `./test_animation_fluency.gd` — six-identity moving-action stride/side/priority registration, actual blocked-movement/release regression, single-cap body selection and lazy historical texture loading.
- `./test_combat_audio.gd` — real bounded mixer/priority/pause/settings, deterministic PCM, resolved/cancelled event observation, threat-cache bounds and crowd-health visibility.
- `./test_profile_store.gd` — profile persistence contract.
- `./test_web_platform.cjs` — browser adapter assertions.
- `./test_performance_web.cjs` — Web diagnostic assertions.
- `./frame_pacing/README.md` — documented frame pacing fixture and device-test limitations.
- `./test_pixel_vixen_cpk_art_gate.gd` — targeted art integration regression.
- `./test_approved_individual_hero_sheets.gd` — six full-atlas resource routes, 384 transparent cells, cached textures and exclusion of the rejected Pixel Vixen derivative; assertions updated for v2, not executed for this delivery at creator request.
- `./frame_pacing/MAIN_BASELINE_PROVENANCE.md` — unchanged-main Windows control and same-runner Linux PR-base control for the approved individual-sheet/full-atlas branches; the historical fixture is preserved rather than silently regenerated.

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

The accepted Neon production continuation updates legacy illustrated-card/feedback expectations in `test_spotlight_theme.gd`, `test_hero_clash_button_motion.gd` and `button_art/test_components.gd`; actual native click, explicit confirmation, hit geometry, reduced motion and RNG assertions remain.

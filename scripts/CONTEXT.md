# Runtime scripts

**Context tier:** deep. **Scope:** `scripts/`.

## Purpose

Godot gameplay, presentation, persistence and build/validation helpers. This navigation document cannot approve or supersede gameplay or art. The operational design authority is GDD V3 and the creator decision register, with canonical approval provenance in `clutchpunks-canon`.

## Key files

- `./solo_run.gd` — active solo-run controller and module integration point.
- `./game_rules.gd` — foundational limits; not the full approved gameplay catalog.
- `./solo_clock.gd` — run clock.
- `./solo_offer_rules.gd` — offers and legal choices.
- `./solo_enemy_rules.gd` — enemy rules and selection.
- `./solo_world_rules.gd` — world rules.
- `./solo_passive_rules.gd` — passive gameplay rules.
- `./phaser_rng.gd` — deterministic Phaser-compatible Mulberry32 sequence.
- `./profile_store.gd` — versioned profile and legacy-save compatibility.
- `./approved_visuals.gd` — visual resource binding.
- `./hero_animation.gd` — hero animation logic.
- `./web_platform.gd` — Godot-facing browser adapter.
- `./validate.sh` — validation orchestrator.
- `./build_web.sh` — Web build/export procedure.

## Architecture and flow

The live `scenes/main.tscn` root attaches `solo_run.gd`, which preloads clock, rules, RNG, profile, visual and platform helpers. `scenes/player.tscn` separately attaches `player.gd`. Do not assume all available scenes are instantiated by the live main scene.

Some content in `docs/ARCHITECTURE.md` describes an early bootstrap and future target layout; do not treat those future `scripts/domain/` or `scripts/simulation/` paths as implemented.

## Invariants and impact

- Preserve GDD V3 gameplay contracts, stable hero/weapon/passive IDs, slot constraints, run timing, offers and balance unless explicitly approved. Verify rules against canon, not runtime defaults alone.
- RNG seed, state and draw order in `phaser_rng.gd` must remain deterministic. Rendering and visual motion must not advance gameplay RNG.
- `profile_store.gd` maintains v2 profile handling and compatibility with legacy storage; do not silently change save keys, migrations or schema.
- Visuals and art bindings must not change collisions, hit outcomes or simulation. Approved-art manifests and hashes control provenance; runtime use is not artistic approval.
- For cross-cutting changes inspect calling modules, scenes, target platforms and focused regression tests before changing interfaces.

## Relevant checks

Commands identified in source, **not run by this context change**. Run from repository root with required tooling:

```sh
godot --headless --path . --script res://tests/test_phaser_rng.gd
godot --headless --path . --script res://tests/test_playable_slice.gd
bash scripts/validate.sh
```

`validate.sh` invokes asset verification/synchronization and several suites; inspect prerequisites and possible side effects before running it. Evidence must include exact SHA, commands, seed/scenario where relevant, platform and real outcomes.

## Related contexts

[Scenes](../scenes/CONTEXT.md) describe entry points; [Tests](../tests/CONTEXT.md) cover contracts; [Web](../web/CONTEXT.md) covers the browser adapter; [Assets](../assets/CONTEXT.md) covers art provenance.

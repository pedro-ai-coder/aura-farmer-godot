# Runtime scripts

**Context tier:** deep. **Scope:** `scripts/`.

## Purpose

Godot gameplay, presentation, persistence and build/validation helpers. This navigation document cannot approve or supersede gameplay or art. The operational design authority is GDD V3 and the creator decision register, with canonical approval provenance in `clutchpunks-canon`.

## Key files

- `./solo_run.gd` — active solo-run controller and module integration point.
- `./neon_menu_backdrop.gd` with `clean_cut_skin.gd` / `clean_cut_secondary.gd` � eleven secondary/choice menus reuse Neon tokens and native input owners; bounded entry rails, reduced motion, fitted actions, dark save editor and cached responsive layouts. Gameplay HUD art and simulation remain separate.
- `./cpk_design_system.gd` — shared native CPK Theme and reusable button/card/panel/label helpers; candidate presentation, no gameplay ownership.
- `./signal_breaker_garage.gd` / `./garage_environment.gd` — separate application entrance, six approved identities, real Solo/Settings handoff, layered candidate environment; retains the existing Solo controller as gameplay/save authority.
- `./game_rules.gd` — foundational limits; not the full approved gameplay catalog.
- `./solo_clock.gd` — run clock.
- `./solo_offer_rules.gd` — offers and legal choices.
- `./solo_enemy_rules.gd` — enemy rules and selection.
- `./solo_world_rules.gd` — world rules.
- `./solo_maps.gd` and `./enemy_navigation.gd` define V4.1 candidate footprints and cover steering in obstacle space. Existing circular covers remain supported.
- `./msg_factory_presentation.gd` and `./msg_factory_plate.gdshader` apply proposed press, terminal, cover and pavement effects using the existing active run clock and reduced-motion setting.
- `./solo_passive_rules.gd` — passive gameplay rules.
- `./phaser_rng.gd` — deterministic Phaser-compatible Mulberry32 sequence.
- `./profile_store.gd` — versioned profile and legacy-save compatibility.
- `./approved_visuals.gd` — visual resource binding.
- `./hero_animation.gd` — hero animation logic.
- `./combat_audio.gd` — original short PCM SFX, eight bounded priority voices, actual emission/contact/Flex/threat observers, modal pause and existing Master settings; no gameplay RNG or external service. Ordinary headless checks disable playback; the focused audio test explicitly exercises the mixer.
- `./full_hero_atlases.gd` — authored 64-frame atlas playback: eight movement directions, front/back idle/attack/hurt, Flex and defeat; replaces provisional pose transforms.
- `./full_hero_atlases.gd` composes distance-driven legs during attack/Flex for all six identities, with per-identity seams after creator approval of the Cool Kid pilot/expansion (2026-11-15). Source pixels remain immutable. Released Sigma body poses exclude baked airborne caps; historical atlas inspection is lazy in `approved_visuals.gd`.
- `./prepare_full_hero_atlases.py` / `./verify_full_hero_atlases.py` — transparent-frame packing and structural file checks; original generated sheets/prompts stay versioned.
- `./approved_hero_sheets.gd` — cached playback of the six creator-approved individual-sheet identities; presentation only, no reflected CPK lettering.
- `./import_approved_hero_sheets.py` / `./verify_approved_hero_sheets.py` — deterministic original-pixel extraction and source/export hash gates.
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

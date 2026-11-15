# Godot scenes

**Context tier:** standard. **Scope:** `scenes/`.

## Purpose and entry points

These are scene resources, not a product specification. `main.tscn` defines the `AuraFarmer` `Node2D` root and attaches `res://scripts/solo_run.gd`. Separately, `player.tscn` defines a `CharacterBody2D` with circular collision, `Camera2D` and `res://scripts/player.gd`. Do not infer that the standalone player scene is instantiated by the active root without checking callers.

## Key files

- `./main.tscn` — solo-play entry scene.
- `./signal_breaker_garage.tscn` — configured application entrance, layered candidate Garage over the unchanged Solo scene; returns to Garage when Solo exits to menu.
- `./level_zero_environment_study.tscn` — separate EXPERIMENTAL factory navigation/entry shotboard; not a Solo replacement or approved combat contract.
- `./player.tscn` — standalone player/camera scene.

## Conventions and change impact

Preserve valid Godot `res://` references when moving scenes or scripts. Treat collision, camera and gameplay attachment changes as contract changes requiring targeted checks. Layout and art adjustments do not authorize changing game rules. Refer to GDD V3 and approved decision records; scenes do not establish canon.

## Targeted validation

A source-defined command, **not run here**:

```sh
godot --headless --path . --script res://tests/test_playable_slice.gd
```

For cross-boundary tasks, read [runtime scripts](../scripts/CONTEXT.md) and [tests](../tests/CONTEXT.md).

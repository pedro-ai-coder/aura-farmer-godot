# Feedverse map layout experiment — incomplete, not production ready

Base: `aura-farmer-godot` main `2f7cfab5d0b498a2d7dade97ec1adf38e58fda50`.
World Bible reference: canon PR #46 head `512d34f92180797fc994120eacf3c58c9665c4ec` (draft; geographic concept approved, individual scenery and geometry proposed). GDD V4.0 and inherited V3 rules take precedence. These are temporary debug presentation names, not stable content IDs.

This folder contains six independently addressable scene files sharing one data-driven debug viewer. Select a scene in the editor and run it, or run e.g. `godot --path . --editor` then open `experiments/feedverse/maps/msg_factory.tscn`. Use arrows/WASD to move, square brackets to switch. Ground polygons and circular cover are defined in JSON; collision is geometric and does not depend on the drawn shapes. The colors and procedural shapes are experimental code-native graybox art; no third-party assets, logos or approved-registry changes are included. The default production scene and existing runtime code are untouched.

## Validation and limitations

- `python3 experiments/feedverse/validate_layouts.py`: sampled spawn validity and connectivity at 20-unit steps for a 40-unit clearance. This is an offline approximation, not a physics or gameplay test.
- Godot parsing, imports, actual scene loading, movement, camera, map switching, line-of-sight, projectile/pickup behavior, determinism, mobile rendering, performance and screenshots have **not** been tested: the environment's Godot executables are broken links to a missing binary.
- Player marker is a debug circle, not an approved hero. No enemy, combat, pickups, touch controls, artwork production kit, gameplay adapter or encounter implementation is present. None of these maps is a playable combat prototype. Collision navigation is a first-pass layout study and must be reworked against actual actor radii and production rules.
- Decoration is schematic; it is not commercial-quality art, approved art, or a substitute for an art pipeline. No performance claims are made.
- Square-bracket switching is an isolated debug convenience, not a production Garage selector.
- No simulation RNG is used. This does not prove deterministic integration with production.

## Next steps

Run Godot 4.7.2 import and scene tests; address errors before further development. Build a separate map-rules adapter and integrate it with the existing simulation without duplicating the controller or changing production defaults. Test all hero kits, obstacle clearance, LOS, spawn, pickups, mobile/desktop views and legacy deterministic behavior. Produce and review candidate regional art with provenance and actual engine captures. Obtain creator approval separately for geometry, art and gameplay decisions.

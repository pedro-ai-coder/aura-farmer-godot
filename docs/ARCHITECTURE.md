# Godot target architecture

This project is an engine bootstrap, not a feature-complete port.

## Boundaries

- `scripts/domain/`: future character/weapon/passive/wave catalog from the GDD.
- `scripts/simulation/`: future deterministic clock, combat, XP, Aura, Flex, RNG and state, independent of scenes.
- `scripts/presentation/`: future gameplay scenes, HUD, animation, camera, VFX and sound. No gameplay RNG in visuals.
- `scripts/platform/`: future keyboard, touch/gamepad adapters, persistence and lifecycle.
- `tests/`: headless contract and runtime tests.
- `assets/`: future inventoried, approved assets from the Phaser repository.

The initial `scripts/game_rules.gd` duplicates a tiny set of explicitly approved constraints; consolidate catalogs as the port proceeds.

## Platform considerations

Web uses Godot Compatibility renderer and GDScript; validate browsers and mobile Web separately. Android requires real touch, rotation, app lifecycle and save tests. iOS native builds require macOS/Xcode signing and safe-area validation. Keyboard movement is the only implemented input in the bootstrap. Performance targets in the GDD are 60 FPS reference desktop and stable 30 FPS reduced profile, pending hardware tests. Legacy browser localStorage will need an explicit versioned migration.

No platform export presets, signing certificates, production deployment or app-store settings are present.

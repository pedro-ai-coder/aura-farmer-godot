# Aura Farmer — Godot

Shared solo implementation for **Web, Android and iOS** using Godot 4.7.2, GDScript and the Compatibility renderer. The canonical `docs/GDD.md` is the gameplay authority. The Phaser reference repository remains unchanged.

## Current state

The three approved starters, nine weapons/legendary variants, active solo passive subset, 3+5 inventory limits, offers, XP/Aura/Flex, five-wave timeline, events and Big Hater logic are implemented with deterministic regression coverage. The Cartoon Arcade UI preserves approved menu art and catalog symbols. Menus include explicit hero Play, options/save navigation, card/replacement confirmation, pause/build inspection, exit confirmation, result retry, preferences and profile transfer. Approved art is fetched from pinned, hash-verified Phaser assets.

This is **not final migration acceptance**. Visual and responsive review is deferred to the owner. Normal-play balance, complete audio/animation polish, real-device lifecycle/export tests, rendered FPS/stress measurements and the 85/100 acceptance score remain outstanding. Read `docs/MIGRATION_PROGRESS.md` and `docs/NATIVE_READINESS.md` for evidence and limits.

## Run and validate

1. Install the exact Godot 4.7.2 editor.
2. Run `python3 scripts/sync_approved_assets.py` to fetch the approved artwork.
3. Import `project.godot`, then run the main scene.
4. Run `bash scripts/validate.sh` for import, gameplay, save, input, art and scene regressions. The Bash validation workflow requires GNU `timeout`.

Select a hero with buttons or 1–3, then press Play or Enter. Move with WASD/arrows or the floating left-side touch joystick. Use E/Space for Flex, M for mouse/automatic aim and P/Escape/B for pause/build. Select upgrade cards with buttons or 1–6, then confirm with the button or Enter. Escape cancels replacement/exit confirmation without resuming combat behind the modal.

## Saves and platform builds

Web uses `aura-farmer:profile:v2` in same-origin localStorage. Native uses an atomic `user://profile_v2.json`; old v1/slice data remains untouched. Main-menu **SAVE DATA / IMPORT SAVE** transfers JSON across browser origins, preserving historical IDs and a Godot backup. No cloud account or cross-save backend is added. Proposed new unlock thresholds remain disabled. Approved Street Snack, Aura Magnet and Safe Spot follow canonical Appendix C.2 and the Phaser recovery contract.

Vercel uses `scripts/build_web.sh` with the official verified engine/templates. Android/iOS presets are preparation only; SDKs, signing identities and device verification remain local prerequisites. No native release is authorized or published.

## Integration workflow

Use one scoped implementation PR at a time. Required automated checks must pass before merging. The owner authorized integration of already approved logic and deferred visual validation on 22 October 2026. This does not approve new mechanics, artwork, paid services, native releases or a claim of complete parity.

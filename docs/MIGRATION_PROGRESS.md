# Godot migration progress

## Verified repository baseline

- Godot main: `ba7c43684d176a06c31a12487badb0cccab966d4`.
- Phaser main inspected: `fdbc67b` (reference only; unchanged).
- PR #17 is merged; no open destination PRs were returned before this iteration.
- The canonical Godot GDD remains authoritative. Phaser includes later recovery/balance work while Godot GDD Appendix C still labels P1–P8 proposals. Those features must not be copied automatically.

## Current iteration: player projectile travel

Replaces instant No Cap/Ratio Blaster damage with moving projectiles, cover rejection, finite range, piercing limits and per-projectile hit memory. Rendering follows projectile positions. Adds arrival/duplicate-hit/restart/cover regression coverage and updates the original instant-hit smoke assertion.

Validation: `git diff --check` passes. Local Godot 4.7.2 matches the repository archive SHA-256, but segfaults even on `--headless --version`; validation stops at import. No local Godot test, browser test, performance measurement or native test is claimed. The change must remain draft until the complete suite and browser verification are available.

## Parity matrix (initial source inspection; not acceptance)

| Area | Phaser reference | Godot implementation | Status / remaining work | Evidence |
|---|---|---|---|---|
| Hero/animation assets | browser hero animation and frame JSON | approved_visuals.gd | Imported; full directional/state/timing review pending | Existing approved-art test; manual pending |
| Enemy/boss assets | browser enemy animation/frame JSON | approved_visuals.gd | Imported; attack/death lifecycle parity pending | Existing approved-art test; manual pending |
| Nine weapons | simulation/weapons.ts | solo_run.gd, weapon_visuals.gd | Projectile draft; delayed areas/legendary secondaries still pending | New projectile tests unrun |
| Passives | simulation/run.ts, inventory.ts | solo_passive_rules.gd, solo_run.gd | Core subset ported; interactions and proc parity pending | Existing passive tests; runtime unverified here |
| Enemy AI/waves | simulation/enemies.ts, run.ts | solo_enemy_rules.gd, solo_run.gd | Event timers/attacks/boss thresholds require detailed comparison | Existing bestiary tests; full run pending |
| Aura/Flex/collectibles | simulation/run.ts | solo_run.gd | Exact activation counting, Flex interactions and drop approval audit pending | Manual pending |
| Menus/HUD/options | browser/app.ts, scene.ts | solo_run.gd | Basic UI present; complete polished parity pending | Desktop/mobile captures pending |
| Profile/save | browser/save.ts | solo_run.gd profile file | Independent Godot summary; Phaser migration missing | Migration tests pending |
| Audio/feedback | browser/audio.ts | Godot presentation | Audit/port pending | Audio checks pending |
| Mobile controls | browser/touch-playfield.ts | floating_joystick.gd, solo_run.gd | PR #17 merged; choice/focus/safe-area/fullscreen review pending | Existing touch test; real device pending |
| Performance | browser render frame meter | Godot runtime | 300 enemies/150 projectiles, 60/30 FPS unmeasured | No acceptance score assigned |
| Cross-platform exports | shared simulation/browser | export_presets.cfg | Web pipeline exists; native setup/device review pending | No native approval |

## Deployment and next priority

No new production deployment or merge in this iteration. Existing PR #17 bot reports a READY preview; this is build evidence only, not a browser validation performed here.

Next: execute the projectile suite in a working Godot environment, verify desktop/mobile preview and finish delayed/legendary weapon behavior. Then complete animation/UI parity and save compatibility. Full run, comparable screenshots and runtime performance remain required before migration acceptance.

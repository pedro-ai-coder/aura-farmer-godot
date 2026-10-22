# Godot migration progress

## Verified repository baseline

- Godot main: `ba7c43684d176a06c31a12487badb0cccab966d4`.
- Phaser main inspected: `fdbc67b` (reference only; unchanged).
- PR #17 is merged; no open destination PRs were returned before this iteration.
- The canonical Godot GDD remains authoritative. Phaser includes later recovery/balance work while Godot GDD Appendix C still labels P1–P8 proposals. Those features must not be copied automatically.

## Current iteration: player projectile travel and weapon timing

Replaces instant No Cap/Ratio Blaster damage with moving projectiles, cover rejection, finite range, piercing limits and per-projectile hit memory. Rendering follows projectile positions. Adds arrival/duplicate-hit/restart/cover regression coverage and updates the original instant-hit smoke assertion.

Validation on 22 October: local Godot 4.7.2 now starts after restoring the complete 146,414,384-byte executable from the SHA-verified archive. A truncated Alpha atlas was restored from the pinned Phaser Git object; all 18 assets pass the manifest hashes. Invalid generated import metadata was removed and regenerated. The full local `scripts/validate.sh` suite passes, including projectile travel and new delayed-area regressions. The earlier engine crash was an incomplete local executable, not a confirmed engine defect.

Additional combat fixes: Brainrot marks a fixed position and resolves after 0.45s; Ban Hammer resolves after its 0.30s windup; Keyboard Warrior and Chad Hands divide damage across the approved two impact times. Shared activation state prevents duplicated primary procs. Origins and directions remain fixed for pending attacks; pause freezes them and restart discards them. Brainrot/Ban warnings describe the real pending geometry.

Further weapon coverage now includes delayed legendary Ratio shots, No Cap line explosion, shared-hit Feed side impacts, Keyboard/Hammer finishers, successful-hit Chad slam conversion, enhanced Grass, weapon shield refresh/expiry, and Personal Space weakness. Secondary hits do not trigger primary procs. All nine weapon IDs have behavioral coverage; this does not establish complete parity. Remaining combat gaps include manual aim, boss stagger, exact area active windows, full passive interactions and all event/boss patterns.

Local `scripts/validate.sh` passed again with `test_legendary_combat.gd`, covering all nine weapons, secondary damage/proc isolation, shield lifetimes/absorption and boss-transition cleanup.

The previous PR head `863e0343a10b5adc86b4180fe8eee8d355f9057e` passes hosted Godot CI. The updated commit still requires hosted checks and interactive preview verification before merge. Vercel connector access returns 403 at `read_protection_bypass`. Browser authentication is now complete, but the authenticated preview reports missing WebGL2 in the remote browser before the game can start. This is a browser execution limitation, not evidence of a game rendering defect. No native, performance, full-run or visual acceptance is claimed.

## Parity matrix (initial source inspection; not acceptance)

| Area | Phaser reference | Godot implementation | Status / remaining work | Evidence |
|---|---|---|---|---|
| Hero/animation assets | browser hero animation and frame JSON | approved_visuals.gd | Imported; full directional/state/timing review pending | Existing approved-art test; manual pending |
| Enemy/boss assets | browser enemy animation/frame JSON | approved_visuals.gd | Imported; attack/death lifecycle parity pending | Existing approved-art test; manual pending |
| Nine weapons | simulation/weapons.ts | solo_run.gd, weapon_visuals.gd | Projectile travel, delayed/paired impacts and legendary transformations ported; manual aim/stagger/full interaction audit pending | Full local suite and nine-weapon regressions pass; browser blocked by missing WebGL2 |
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

No production deployment or merge in this iteration. The previous preview is Ready, and browser authentication is complete, but the remote browser reports missing WebGL2. Interactive gameplay verification remains required. Local validation now works and the updated combat suite passes; hosted checks must also pass on the new commit.

Next: verify the authenticated preview in a WebGL2-capable browser and merge only after all required checks. Continue boss stagger, manual aim and the full combat interaction audit. Then complete animation/UI parity and save compatibility. Full run, comparable screenshots and runtime performance remain required before migration acceptance.

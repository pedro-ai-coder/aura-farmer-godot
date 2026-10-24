# Gameplay HUD Art Rework — Creator Changes Requested

**Status:** replacement art candidate; pending creator review. This package answers the Gameplay HUD rejection on PR #69. The rejected `v2/screens/gameplay-hud/gameplay-hud.svg` and preview remain untouched for comparison. The Main Menu, Hero Selection, Three-card Upgrade, and Six-card Legendary comps are unchanged and remain separately reviewable.

## Package

- `screens/desktop-hud.svg`: compact hero-linked status, signature wave clock, actual weapon/passive icons, Flex, pause.
- `screens/mobile-landscape-hud.svg`: landscape touch arrangement with 80-unit outer-ring and 35-unit thumb art; thumb is shown only as an active-touch illustration. The intended interaction remains full-playfield floating as specified by GDD Annex C.1.
- `screens/combat-density.svg`: real Sigma and Hater masters, hostile attack telegraph, XP shard, recovery pickup, 3 weapon icons, 5 passive icons, and active Flex state.
- `screens/boss-warning.svg`: 09:30 warning illustration for the 10:00 Big Hater arrival.
- `screens/boss-encounter.svg`: real Big Hater master, boss health/phase art, warning telegraph, and the recoverable 12:00 berserk state.
- `screens/full-hater-mode.svg`: separate FULL HATER MODE transition composition for the actual boss state.
- `screens/pause-default.svg`: pause composition; isolated default/focus/pressed/disabled button-state SVGs are in `shared/pause/`.
- `shared/`: independent SVG component artwork, interaction states, and separated VFX sprites; approved masters are byte-preserving source copies.
- `previews/`: rendered PNG review comps. SVG sources remain the editable production masters.
- `manifests/`: source provenance, candidate status, geometry and state inventory.

The compositions are art references, not runtime screenshots or implementation. Variable values, labels, event state, and visibility remain live-GDD data. The health, event and Flex examples are representative state art, not gameplay instructions. Existing creator-approved catalog icon PNGs are reused byte-for-byte from v1; the new HUD and VFX art remain candidates pending creator review.

## Comparison

The rejected HUD is preserved at `../screens/gameplay-hud/gameplay-hud.svg` and `../previews/gameplay-hud.png`. Review the new desktop, mobile, dense-combat, warning, and boss compositions in `previews/`; the new package removes full-width top/bottom bands and proves combat-space legibility with approved characters, actual inventory icons, and illustrated state cues.

## Runtime / accessibility handoff

Use SVG parts as component artwork and bind status to game state; do not ship a static screen. Preserve GDD typography and semantic colors. Keyboard focus has an explicit outline/high-contrast state; motion must respect reduced-motion settings. Keep functional touch targets at the GDD size, preserve UI-hit priority and safe insets, and let the joystick start anywhere on unobstructed playfield terrain. This art package does not implement or validate those runtime behaviors.

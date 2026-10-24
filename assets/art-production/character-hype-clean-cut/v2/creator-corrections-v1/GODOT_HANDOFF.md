# Godot art handoff

Build live Controls from the SVG masters and import their transparent PNG exports. Use anchors/containers and read the actual safe area. Never use a full-screen preview as a runtime texture.

## Input contract

1. Test hit priority against actual visible interactive rectangles. Eligible world touch-down creates the ring at the touch point, clamped only by safe-area bounds.
2. Capture the first eligible pointer as movement owner; normalize its vector by the 119-unit saturation radius without changing character speed. Keep ring at touch origin and thumb at clamped displacement.
3. Independent second pointer may press Flex; it never reassigns movement. UI-started touches never become movement during drag.
4. Hide ring/thumb on release and clear state on pointercancel, focus loss, pause, modal, run end, viewport invalidation/orientation change.
5. Retest at desktop 1600×900 and 1280×720 plus landscape 915×412, 844×390 and safe-area variants. Check movement-only touches at left/center/right; Flex-only and Pause/card touches; movement+Flex two-finger; release/cancel/focus/pause/modal/restart; no stuck movement or accidental scroll.

## Data and interactions

Player status, equipment slots, rarity/level, upgrades, comparisons, offers, Flex charge/state/duration and event clocks are dynamic. Bind stable item/hero IDs. Normal choices: exactly three legal offers and explicit confirmation. Legendary: exactly 3 compatible weapon evolutions + 3 legal passive buffs, one pick/run; preserve deferral and 6:00/8:00/9:55 windows. No menu label may be painted into a background. Preserve focus/pressed/disabled states and touch targets at least 48 px.

The exports are visual assets only. This package does not edit runtime, GDD, scenes, simulation, input ownership, physics or balance.

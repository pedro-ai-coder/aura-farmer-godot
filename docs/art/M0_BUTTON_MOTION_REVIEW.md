# M0 Hero Clash UI — Button and Micro-Animation Review

**Status:** In review on PR #80; no production artwork promotion, no automatic merge.
**Source of truth:** GDD V3.0 §§7.2, 8.3–8.5 and creator's latest UI feedback.

## Visual treatment

The previous candidate provided only a tiny button scale tween and two flat lines.
This revision replaces that with a cohesive, original touch-safe button language:

- Three distinct edge layers: restrained ink recess, light top bevel, accented lower lip.
- Angular gold/cyan corner graphic, stronger primary CTA hierarchy.
- Mouse hover and keyboard focus edge illumination.
- Pressed depth compression INSIDE the button's static rectangle; on release,
  a short accent highlight replaces any simulated double-tap action.
- Selected card receives corner highlights and a brief one-time selection cue,
  while approved card artwork and icons remain untouched.
- Staggered, short entrance sheen on menu/hero/card/modal buttons and a concise
  title accent on screen transitions. No full-screen flash or persistent UI storm.
- Ready Flex's existing circular animation remains the hero's signature ability
  cue. It does not auto-activate or change Aura, power, recovery or cooldown.

## Interaction and accessibility invariants

All effects render using mouse-ignoring child Controls attached to the existing
Godot Buttons. The action's position, size, scale, focus and pressed signals
remain authoritative and unaltered. No simulated gameplay RNG consumption.
The first gameplay terrain touch continues to own joystick movement; an independent
touch can activate Flex. A pointer released outside a button may not activate it.
Reduced Motion disables entrance and repeat motion while preserving clear state
edges. Avoid bright full-screen effects and combat telegraph occlusion.

## QA / owner review

Validate desktop 1280×720, mobile landscape 915×412 / 844×390 and portrait
390×844 in actual Godot output, then Web and physical mobile. Inspect normal,
hover, focus, pressed, selected, disabled, READY and reduced-motion states.
Check real Quit, Hero Selection, Play, Upgrade selection and confirmation.
The art direction requires explicit creator review regardless of green CI.

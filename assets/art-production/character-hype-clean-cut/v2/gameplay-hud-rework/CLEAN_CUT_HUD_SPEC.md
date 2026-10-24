# Character Hype Broadcast — Clean Cut HUD Art Specification

**Review state:** candidate pending creator review. **Scope:** gameplay HUD art only; the GDD remains authoritative.

## Visual identity

Build a character-led arcade broadcast from cut-paper silhouettes, inked contour lines, slanted labels, compact object-shaped UI, hard offset shadows, halftone accents, and selective cream/navy/gold/blue with coral for danger. Keep most of Ruin Alley open. A player portrait anchors a small upper-corner status mark; a floating wave clock reads as a numbered arcade token; equipment is shown with the approved illustrated icons; the chosen hero’s Flex owns one distinctive action emblem. Enemy telegraphs use an unmistakable red wedge/ring plus outline and pattern. The screen should feel drawn and assembled, not like boxes laid over a gradient.

Typography stays within GDD §26.1: Inter Display Black 900 for headings, Inter Black 900 for controls, Inter ExtraBold 800–900 for item names, Inter SemiBold 600 for HUD numerals, Inter Medium 500 for descriptions. Lettering can be stacked, angled, outlined, or offset; use a separate illustrated wordmark. Keep text selectable in live UI and readable at supported scale.

## V5 visual rules superseded for HUD presentation

| Superseded V5 convention | Clean Cut HUD rule |
|---|---|
| Wide, uniform top/bottom HUD slabs | Keep map visible; place compact identity, clock, equipment, and Flex modules as independent object-shaped marks |
| HP, wave, timer, and boss countdown all in generic boxes | Make health portrait-linked; wave/time use one arcade clock token; boss state gets its own illustration only when that state is active |
| Text-only weapon/passive counters | Show three weapon and five passive icon slots with the exact approved PNGs; retain live accessible names and slot labels in UI |
| Flex duplicated in footer and action area | One hero-specific control with Ready, Active, Focus, Pressed, Disabled, and Recovery art states |
| One generic joystick treatment | Separate outer ring and thumb artwork; mobile landscape only; full-playfield floating gesture is governed by Annex C.1 |
| Uniform visual composition across desktop/touch | Desktop favors corner-pinned reference modules; mobile landscape makes the floating touch ring visible and reserves its area around active input |
| Empty arena preview as proof of HUD | Use approved hero/enemy/environment masters, readable hostile telegraphs, XP, and recovery pickup in dense-combat art |
| Generic navy gradient default | Use the unchanged approved Ruin Alley environment master as the gameplay ground |

## Canonical content and interaction

- Heroes and Flex names: Sigma — Deadpan Verdict; Cool Kid — CTRL + CHAOS; Alpha Chad — Giga Chad Rampage.
- Inventory capacity shown: three weapons and five passives. Example icons are approved source assets; offers and run values remain data-bound.
- Timing: warning at 09:30, Big Hater at 10:00, recoverable berserk after 120 seconds of boss combat at 12:00. No hard run timeout. Never use the historical 15:00 boss / 18:00 berserk.
- Health art states distinguish healthy, damage, healing, critical, and shielded with labels, pattern or shape as well as color.
- Boss states include warning, name/health/phase, attack telegraph, berserk, and FULL HATER MODE. Use only when actual simulation state is active.
- Focus is explicit and high contrast; pressed/disabled states have distinct shape/tone; color is never the only status cue. Support reduced motion.
- Annex C.1 stays binding: joystick starts on any unobstructed terrain, its outer ring/knob scale is approximately 80/35 units (from 57/25), travel approximately 119 units (from 85); hide when no touch is active; UI hit regions take priority. This is art direction only, not a behavior implementation claim.

## Production note

All new screens, HUD components, word treatments, and generated FX are candidates pending creator review. The existing creator-approved hero, enemy, map, and 37 catalog-icon PNG masters are not altered. Previews are composition references, not runtime captures. No Godot runtime, scenes, gameplay, GDD, or Phaser files are part of this change.

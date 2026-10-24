# Asset index — Clean Cut v2

All screen compositions are static 1600×900 art references. The separate SVG and PNG sources below are intended for live UI implementation. Variable copy, values, offers, timers, and state come from canonical game data.

| Screen | Composition and preview | Reusable artwork | States and data notes |
|---|---|---|---|
| Main Menu | screens/main-menu/main-menu.svg; previews/main-menu.png | menu-poster-bg-candidate.png, aura-farmer-wordmark-candidate.svg, Sigma source master, primary/secondary buttons, slash and crown accents | default, hover, focus, pressed, disabled; actions remain live UI |
| Hero Selection | screens/hero-selection/hero-selection.svg; previews/hero-selection.png | isolated Sigma, Cool Kid, Alpha Chad masters; hero card frame idle/selected; hero-selection-bg.svg | one visible focus/selected example; only the three canonical starter heroes |
| Gameplay HUD | screens/gameplay-hud/gameplay-hud.svg; previews/gameplay-hud.png | unchanged Ruin Alley master, HUD plate, HP/XP meter frames, joystick, Flex control, pause art | default/focus for key controls; values are illustrative slots, bound to simulation |
| Three-card Upgrade | screens/upgrade-three-card/upgrade-three-card.svg; previews/upgrade-three-card.png | projectile, passive-shield, and feed card frame shapes; upgrade background; approved catalog icon references | idle/hover/focused examples; one highlighted offer; three legal offers and effects stay data-bound |
| Six-card Legendary | screens/legendary-six-card/legendary-six-card.svg; previews/legendary-six-card.png | legendary frame idle/hover/selected; legendary background; approved weapon/passive icon references | 3×2 composition, one focus state; one selection; 06:00 / 08:00 / 09:55 schedule |

## Shared interactive component states

- Buttons: primary and secondary default, hover, focus, pressed, disabled SVGs.
- Hero cards: idle and selected SVGs, with selected check shape.
- Upgrade cards: idle, hover, focused and type-specific frame silhouettes.
- Legendary cards: idle, hover and selected/focus frame variants.
- HUD: HP and XP frames; joystick; Flex default/focus; pause default/focus.

New art is a production candidate pending creator review. Approved source-master copies preserve exact source bytes and are hash-listed in SOURCE_PROVENANCE.json. Approved icon bytes are referenced from v1 and not changed here.

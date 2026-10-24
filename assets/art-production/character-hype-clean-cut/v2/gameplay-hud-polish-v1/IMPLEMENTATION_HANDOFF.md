# Godot Art Implementation Handoff

## Reference geometry and anchors

All anchor points use a 1600×900 reference. Suggested safe inset: 32 px (desktop), 24 px at 1280×720 and 12 px in the authored 915×412 constrained reference. These are art anchors; implementation must read actual platform safe areas.

| Module | Desktop reference box | Anchor / rule |
|---|---|---|
| Player identity + HP | x24 y22, 452×198 | Upper-left safe area. Portrait occupies left third; HP/shield labels and values stay live. |
| Level + XP | x24 y191, 490×82 | Immediately beneath status. XP is one bar; Aura remains in the Flex state, never merged with XP. |
| Wave + simulation time | x654 y24, 280×124 | Upper center; event/transition state swaps the same token, not another permanent slab. |
| Pause | x1478 y30, 98×110 | Upper-right; functional hit target must be at least 48×48 px in the actual viewport. |
| Equipment build | x26 y666, 515×250 | Bottom-left; 3 weapon icons/slots then 5 passive icons/slots, selected state accessible by keyboard/touch. |
| Flex | x1295 y680, 318×182 | Lower-right safe area; one control only, different role art per hero. Minimum functional target remains 48 px. |
| Floating joystick | 240×240 artwork / approx 80-unit ring radius | Position follows eligible touch-down anywhere on unobstructed visible terrain; clamp only for safe area. Do not fix it to the left. |
| Boss information | top center, <=640×132 | Boss title/HP/phase in one component; countdown/state as one compact continuation row; hostile telegraph always has higher contrast. |

The 915×412 example uses dedicated compact status, progression, equipment, Flex and pause art. It retains live values at readable size and does not scale a 1600-pixel screenshot into an inaccessible miniature.

## Source components

Use `shared/status`, `shared/progression`, `shared/equipment`, `shared/flex`, `shared/flex-fx`, `shared/joystick`, `shared/boss`, `shared/pause`, `shared/pickups`, `shared/effects`, and `shared/enemies`. Full compositions in `screens/` are review guides only. PNG enemy crops are derivatives of unchanged approved atlas masters, with rectangles and source hashes in `SOURCE_PROVENANCE.json`.

Bind HP, max HP, shield amount, XP, level, wave/time, offers, weapon/passive IDs, rarity, item level, Flex charge/state/duration, boss health/phase/event and pause mode to canonical GDD data. Example numbers are not authority. Empty/equipped/selected item art changes from live slot state, never baked into screen backgrounds. Use approved icon hashes as manifest guards.

## Platform and accessibility contract

Maintain ≥48 px functional controls; move modules around—not over—safe insets and active combat. Announcements remain readable with reduced motion. Pair coral danger with a distinct chevron/stripe/warning label; pair green healing with plus/heart and a label; pair blue shield with a separate outline and “shield” text. Focus treatment uses a visible high-contrast blue keyline; pressed is a distinct inverted cut plate; disabled uses desaturated art plus “unavailable”. Maintain text alternatives and semantic role names for actual UI.

This handoff specifies static art, not input ownership or game logic. The GDD Annex C.1 acceptance remains: full-playfield floating movement, UI-hit priority, first eligible finger ownership, independent second-finger UI interaction, release/cancel cleanup and real safe-area validation. No such behavior was changed or tested here.

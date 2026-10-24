# Character Hype Broadcast — Clean Cut HUD Art Specification

**Review:** Clean Cut visual direction accepted. New individual assets remain `PRODUCTION_CANDIDATE_PENDING_CREATOR_REVIEW`.

## Retained visual identity

Carry forward the current accepted package: expressive original Option A character silhouettes, approved Ruin Alley master, open map space, hard-edged cut-paper modules, asymmetric cuts, inked cartoon contours and restrained comic marks. Source character art stays untouched. Custom HUD artistry is made from new isolated layers around approved source icons and masters. FX stay below hostile telegraphs in the reading order.

## Production tokens and typography

- Navy `#253449`, deep ink `#13233A`, panel blue `#1F3E63`, warm paper `#F7EDCD`, aura gold `#F8C45F`, sky blue `#4EA3FF`, Hater coral `#E57461`, support teal `#6EAAB0`, Cool Kid magenta `#F04BA5`, epic violet `#A66BFF`, healing green `#78C85C`. Use color with text, outline, shape, or pattern; never as the only state cue.
- GDD §26.1: Inter Display Black 900 headings, Inter Black 900 controls, Inter ExtraBold 800–900 item names, Inter SemiBold 600 HUD numbers, Inter Medium 500 descriptions. Preserve tabular numerals. These approved font resources already exist; no font binaries were added.
- Reference compositions: 1600×900; standard 1280×720 render; responsive constrained example at 915×412. Screen art is composed from parts and anchored with Godot Containers/safe areas.

## HUD relationship

Portrait + hero label + HP form one compact status silhouette. Shield has its own outlined blue layer. A separate level/XP strip shows level and XP only; the wave token owns wave/time. Three weapon and five passive icons occupy a compact two-row equipment cluster. Distinct rarity labels/notch counts supplement token color. One hero-specific Flex control communicates its actual state. Pause remains one upper-right hit target. Boss title, health, phase, attack cue, berserk countdown and full-mode state share one compact hierarchy rather than several banners.

## V5 visual conventions superseded for this HUD only

| Older V5 HUD convention | Current Clean Cut HUD treatment |
|---|---|
| Repeated horizontal HP / XP / wave slabs across the top | Portrait status at safe upper-left; level/XP below; asymmetric wave token separated at upper-center |
| Identical navy rectangular treatment for every status family | Distinct portrait, numbered clock token, two-row equipment composition, hero-specific Flex silhouette, one pause glyph |
| Text counts standing in for equipped inventory | Actual unchanged approved 256px PNG icons in each of three weapon and five passive slots |
| One generic Flex button repeated in secondary HUD areas | One button; unique target/keyboard/shield motif per hero, one state label and only canonical state telemetry |
| Fixed left joystick zone or decorative joystick corner | Floating ring/thumb demonstrations at three free-playfield positions; interactive UI retains priority |
| Empty arena as the principal HUD proof | Mid/late/boss stress compositions use approved Option A enemy families, projectiles, crystals, pickups and hostile floor telegraphs |
| Stacked large boss banners | Single boss bar/phase; one compact event/state line; attack danger cue remains visually primary |

The package preserves V5’s approved typography, token palette, actor identity, platform priority, target sizes, live UI/data binding and readability requirements. Supersession applies to visual composition, not to gameplay, content, accessibility, or platform contracts.

## Candidate boundaries

Screens, generated cut-paper components, icon frames, pickup glyphs, projectiles and Flex VFX are candidates, not newly approved identity art. The exact 37 approved icon sources and approved Option A masters retain their earlier approval only at the recorded hashes. A static composition can communicate the intended artwork; it cannot assert runtime behavior.

# Clean Cut final art corrections — creator candidate

**Direction:** approved to continue. **Individual correction assets:** production candidates pending creator approval. This package preserves the prior v2 screens and HUD packages unchanged.

## V5 visual rules superseded for these five screens

- Repeated uniform rectangular HUD slabs → asymmetric plate hierarchy with separate HP, XP, Wave, item build and one hero-specific circular Flex control.
- Fixed/decorative directional joystick artwork → circular floating analog ring/thumb, shown only while an eligible movement touch is held; never a permanent on-screen stick.
- Diamond/arrow joystick geometry → rejected and absent from this candidate package.
- Generic triangular Flex trigger or duplicate READY chips → one circular hero-identity button; the live state and its single status label are data-bound.
- Three same-looking upgrade cards → type-aware weapon/passive cards with current→new comparison, focus/hover/pressed/selected state and confirmation step.
- Legendary cards styled like normal upgrades → crown/gold entry hierarchy and distinct weapon-evolution/passive categories, while keeping 3×2 choices and a deferral action.
- Hero selection without loadout identity → only Sigma/Cool Kid/Alpha, each with role, approved starter icon/name and current Flex name.

Retained V5 foundation: approved Clean Cut palette, Inter production typography for UI/body copy, illustrated Option A identities, street-poster/cut-paper geometry, current approved logo master and icon PNGs. Screen headlines supersede Inter-only V5 title styling with italic, skewed display lettering, hard-offset print color and a narrow keyline; runtime title font packaging must be confirmed at import. No game rules are changed.

## Mobile analog-control geometry

Outer ring is a perfect circle with **160 px diameter (radius 80)** at 1× reference; isolated circular thumb is **70 px diameter (radius 35)**. Documented movement saturation travel is **119 reference units**; visual thumb displacement in comps is illustrative only and does not encode movement speed. Artwork has transparent idle/pressed/activation layers. Ring is translucent blue/navy with cream outline; thumb is brighter blue or gold when pressed. There is no fixed anchor; left/center/right examples show touch-origin placement.

Runtime integration must preserve GDD Annex C.1: any unobstructed gameplay terrain, actual interactive UI has hit priority, first eligible finger owns movement, a second finger can use Flex independently, and release/cancel/focus-loss/pause/modal/run-end/orientation clears movement. Touches that start on UI never convert to movement. Safe-area and pointer ownership behavior still require tests in the real Godot build. These art comps do not claim to validate input.

## Canonical source of truth

- Starter heroes remain stable IDs: sigma / No Cap / Deadpan Verdict; cool-kid / Keyboard Warrior / CTRL + CHAOS; alpha / Cope Shield / Giga Chad Rampage. Other six heroes are absent from playable choices.
- Use latest GDD §§7.1–7.2, 8–10, 25–26 and Annex C.1 for live values and flows. Flex durations remain Sigma 6 s, Cool Kid 5 s, Alpha 6 s; no invented mechanics.
- Normal level-up remains three legal choices and requires confirmation. Legend remains three compatible weapon evolutions plus three legal buffs, one per run; event times 6:00 / 8:00 / 9:55.
- All numbers, rarity, levels, offers, HP/XP/time, charges and state labels in actual UI must bind to simulation data. Text in previews is illustrative; no offers are newly authorized.

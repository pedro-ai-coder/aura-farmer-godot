> **Current update — 24 October 2026:** The creator explicitly approves 37 exact PNGs: eight V5 weapons, 28 V5 passives and Touch Grass Clean Cut v2. Clean Cut is the selected visual refinement recorded in GDD §26. All selected copies are hash-verified and promoted; 32 current items use live bindings, five future-only passive artworks remain unoffered. See `docs/art/CREATOR_ICON_APPROVAL_2026-10-24.md` and `docs/art/CLEAN_CUT_INTEGRATION_ACCEPTANCE.md`. Earlier zero-approval/blocked statements below are historical checkpoints. Original source isolation and all gameplay rules remain intact.

# Hero Spotlight V5 — Production Art Direction and Developer Handoff

**Status:** CREATOR-APPROVED VISUAL ITERATION, 23 October 2026.  
**Direction:** Option A / Cartoon Arcade, refined to **Arcade Street Clean — Hero Spotlight**.  
**Gameplay authority:** [Godot GDD §26 and Annex A](../GDD.md).  
**Delivery master:** *Aura Farmer — Production Visual Art Bible v5.0* (56-page PDF and editable DOCX, supplied by the creator in the Aura Farmer art conversation), accompanied by *Aura Farmer — Visual Production Handoff v5.0*.

This document records the approved visual decision for developers. It is not a substitute for the illustrated PDF/DOCX: the **22 finished-look scenes** and the **37 isolated icons** are part of the source delivery. The binary PDF, DOCX and PNG/SVG export bundle **are not stored in this repository by this documentation-only change**; import and verify those files before claiming asset integration. Do not substitute the text below for the actual approved imagery.

## 1. Direction and precedence

The target is **a finished-looking illustrated game**, not blue-box wireframes, generic neon dashboards, unstyled Godot controls, recolored placeholder glyphs or static screen composites used as functional UI.

- Hero-first composition: large expressive character artwork; recognizable silhouette and apparel preserved from approved Option A source masters.
- Clear urban arcade UI: ink/navy chassis, warm cream surfaces, gold CTA, restrained crown and speed-line motifs, compact cards with illustrated symbols.
- Physical, cartoon rendering: dark outer contour, 1–2 cel-shade masses, short shadows, punchy impact animation; decorative texture must never compete with hostile telegraphs.
- Each presentation screen in the delivery defines **what the final live Godot scene should resemble**; render the underlying content as live UI/widgets and sprites, not one noninteractive flattened image.
- The approved visual *style* and its composed targets supersede the **visual layout and fonts in the earlier v2–v4 studies**. Existing Option A actor/environment masters remain source references; this approval does not erase their provenance.
- **The current GDD takes priority over stale gameplay labels or balance values captured inside illustrative V5 screens.** Especially: the 10:00 Big Hater schedule in §25 and the Flex identities in §7.2. Never restore 15-minute timers, Cool Kid contact immunity, Sigma Stare, or Alpha Hold because of a scene label.

## 2. Production visual tokens

| Category | Approved production rule |
| --- | --- |
| Render reference | 1600 × 900 composition (16:9), corresponding to 1280 × 720 GDD baseline at 0.8×; anchor responsive containers rather than hard-coded screen coordinates |
| Custom logo | Separate illustrated **AURA FARMER** wordmark, comic shape, gold/white lettering with navy stroke; raster menu composites are not a font |
| Display | **Inter Display Black 900**, uppercase, approx. 60–80 px at reference render; legible short shadow/stroke |
| Buttons/headings | **Inter Black 900**, uppercase, approximately 28–40 px at reference size |
| Cards | **Inter ExtraBold 800–900**, 24–30 px at reference size; no truncation of legal names |
| HUD numbers | **Inter SemiBold 600**, tabular numerals, 20–37 px as context requires |
| Functional body | **Inter Medium 500**, 18–22 px; supporting notes 16–18 px and readable on device |
| Spacing | 8 px baseline; steps 4, 8, 16, 24, 32, 40, 48, 64 px |
| Main button | Reference height 72 px, radius 15 px, 4 px dark outline, 8 px short lower shadow; live idle/focus/hover/pressed/disabled states |
| Secondary button | Reference height 72 px, radius 15 px, 4 px contrasting outline, navy fill |
| Hero select card | Approx. 445 × 576 px at reference, radius 24 px, 6 px selected rim; expressive portrait and short role/starter/Flex summary |
| Normal upgrade card | Approx. 386 × 480 px at reference, radius 24 px, 7 px rarity rim, 45 px rarity strip, large isolated illustration |
| Legendary card | Approx. 430 × 300 px at reference, gold 5 px rim; **six legal offers as a 3 × 2 layout** |
| Panel/interaction motion | Button press 100–150 ms; panel entry 180–240 ms; card reveal 180–260 ms; cosmetic timing never affects simulation |
| Touch | Responsive controls; approx. 48 px minimum hit target (larger where needed); actual usable safe areas and orientation-lock fallback |
| Source font license | Verify and bundle properly licensed font files in implementation. The concept art image does not grant redistributable typeface bytes. |

### Semantic palette

| Token | Value | Role |
| --- | --- | --- |
| \`ink.navy\` | \`#253449\` | GDD-approved outline/primary text |
| \`ink.deep\` | \`#13233A\` | Dark overlays and strong contrast |
| \`panel.blue\` | \`#1F3E63\` | Secondary controls and HUD |
| \`surface.paper\` | \`#F7EDCD\` | Cream surface for cards and dialogs |
| \`aura.gold\` | \`#F8C45F\` | Hero CTA, ready Flex, legendary |
| \`selected.sky\` | \`#4EA3FF\` | Focus, selection and ranged accents |
| \`hater.coral\` | \`#E57461\` | Enemy/hazard accents |
| \`support.teal\` | \`#6EAAB0\` | Shields/support |
| \`cool.magenta\` | \`#F04BA5\` | Character-action accent |
| \`epic.violet\` | \`#A66BFF\` | Epic rarity |
| \`healing.green\` | \`#78C85C\` | Recovery effect |

Rarity has an icon/word/frame distinction as well as color. Danger, healing and protection need distinct geometry, motion and sound, not color alone.

## 3. Scene-by-scene visual targets

The production handoff contains these exact **22 presentation frames**, each with its own technical scene sheet in the illustrated Art Bible. Use the **corresponding frame** when implementing the scene; do not substitute a wireframe.

| No. | Source preview | Production requirements |
| --- | --- | --- |
| 01 | \`screens/01_main_menu.png\` | Hero Spotlight portrait + illustrated logo; **PLAY / HEROES / SETTINGS** as three dominant rounded buttons; context-only exit action. Gold primary and blue secondary actions. |
| 02 | \`screens/02_hero_select.png\` | Three selectable launch hero portraits (Sigma, Cool Kid, Alpha Chad), distinct role/starter/Flex data, selected rim and details; six later GDD heroes must not look selectable prematurely. |
| 03 | \`screens/03_gameplay_hud.png\` | True game viewport; compact HP/shield, XP/level, wave/clock, Flex and boss presentation. Live game sprites and telegraphs sit above the map, UI above world. |
| 04 | \`screens/04_level_up.png\` | **Three** legal weapon/passive choices. Illustrated icons, rarity, slot info, current→new effect comparison and explicit selection/confirmation. Pause simulation. |
| 05 | \`screens/05_legendary.png\` | **Six** legal cards — three weapon and three passive — with gold visual identity, choose/defer, one-per-run rules; live labels from GDD. |
| 06 | \`screens/06_pause.png\` | Dim live game, a single overlay modal, resume/settings/exit semantics, no stacked modal. |
| 07 | \`screens/07_settings.png\` | Clean live toggles/sliders/tabs with accessible focus and touch controls. |
| 08 | \`screens/08_victory.png\` | Strong outcome title, hero art, actual results/build data, primary replay/navigation action. |
| 09 | \`screens/09_defeat.png\` | Matching defeat hierarchy, results context and retry/navigation; do not report a successful run. |
| 10 | \`screens/10_boss_encounter.png\` | Actual approved encounter, clear boss HP, telegraphs and phase cues. Must match canonical 10-minute clock. |
| 11 | \`screens/11_mobile_landscape.png\` | Same gameplay, safe-area HUD, **left floating joystick and right Flex**; robust pointer cancellation/orientation fallback. |
| 12 | \`screens/12_build_panel.png\` | Show three weapon slots and five passive slots, levels, rarity, cap/locked states and supporting effect details. |
| 13 | \`screens/13_flex_sigma.png\` | Sigma cinematic cue, target lock + 1/3–3/3 progress and single **Deadpan Verdict** payoff per GDD. |
| 14 | \`screens/14_flex_cool_alpha.png\` | Cool Kid **CTRL + CHAOS** keyboard combo and Alpha **Giga Chad Rampage** shield/slam/finisher, not historical Flex mechanics. |
| 15 | \`screens/15_weapons_gallery.png\` | Nine illustrated readable weapon icons and action silhouettes; common sprite family. |
| 16 | \`screens/16_passives_gallery.png\` | 28 standalone passive icons corresponding to stable GDD IDs; rarity remains a card frame concern. |
| 17 | \`screens/17_enemy_bestiary.png\` | GDD enemy and boss identities with readable silhouettes, behavior types and support/charge/ranged distinction. |
| 18 | \`screens/18_pickups.png\` | XP, Street Snack, Aura Magnet and Safe Spot art language; only §C.2-approved functions active by default. |
| 19 | \`screens/19_wave_transition.png\` | Readable wave title/event transition over gameplay, with canonical two-minute wave boundaries. |
| 20 | \`screens/20_full_hater_mode.png\` | Full Hater Mode transition and visual telegraphs, boss regen/readable warnings; canonical berserk after 120 s boss combat. |
| 21 | \`screens/21_quit_confirm.png\` | One confirmation layer, clear cancel/exit actions, no simulation continuing behind modal. |
| 22 | \`screens/22_safe_spot.png\` | World-space ring and cooldown/progress feedback, grounded to approved Ruin Alley placement and radius. |

Any illustrative counter, level, weapon damage, character pose or content variant used solely to demonstrate the picture must resolve to real runtime catalog/state rather than becoming a new rule.

## 4. Standalone icon export contract

The source handoff contains:

- **Nine weapons**: \`ban-hammer\`, \`brainrot-feed\`, \`chad-hands\`, \`cope-shield\`, \`keyboard-warrior\`, \`no-cap\`, \`personal-space\`, \`ratio-blaster\`, \`touch-grass\`.
- **28 passives**: \`absolute-cinema\`, \`aura-viral\`, \`big-chad\`, \`big-meme\`, \`brainrot-rain\`, \`built-different\`, \`caught-4k\`, \`certified-w\`, \`cope-harder\`, \`ego-check\`, \`get-ratiod\`, \`hands-on-sight\`, \`homie-check\`, \`its-over\`, \`let-him-cook\`, \`main-character\`, \`no-cap-streak\`, \`no-u\`, \`six-to-seven\`, \`so-back\`, \`take-l\`, \`terminally-online\`, \`thick-skin\`, \`timeline\`, \`too-sigma\`, \`uno-reverse\`, \`w-squad\`, \`w-wifi\`.

Each ID has an isolated **transparent PNG and SVG** at \`icons/weapons/<id>.*\` or \`icons/passives/<id>.*\`. Source icon canvas is 256 × 256, legible at 64 × 64 and at 32 × 32. Contours have a strong external stroke, broad flat color and concise internal highlights; do not crop a full game-screen poster into a shipping icon. Rarity styling is applied by the card frame.

The handoff also contains \`visual_tokens.json\`, \`manifest.json\` and \`README.txt\`. Validate manifests and hashes during import. **The visual approval authorizes the target appearance; independent in-engine alpha, legibility, scaling and platform review remain required before shipping.**

## 5. Asset preservation and runtime boundaries

Keep \`docs/APPROVED_ART_IMPORT.md\` and its pinned imported original artwork intact. The source masters, current atlas masks, navigation/collision shapes and animation timings must not be mutated by replacing UI art.

- Existing approved hero masters: Sigma, Cool Kid, Alpha Chad.
- Existing approved environments: Ruin Alley, Crown Court, Toxic Garden; only Ruin Alley is playable in current solo MVP.
- Existing enemy and boss runtime sheets remain the baseline for gameplay presentation and further art refinement.
- Approved recovery mechanics: Street Snack, Aura Magnet, Safe Spot per GDD Annex C.2; no extra drops from art previews.
- Gameplay events, content limits, latest Flex contracts and timing belong solely to the **canonical GDD**.
- Keep Phaser unchanged. Implement this presentation in the independent Godot 4 project for equally important Web, Android and iOS targets.

## 6. Production acceptance

- Compare **real Godot captures** to each of the 22 approved composition targets at a reference 16:9 desktop viewport and representative mobile landscape sizes.
- Verify all 37 standalone icons at 32 × 32 and 64 × 64; inspect alpha edges and consistency against the source image.
- Validate no button uses baked text, no flat UI image blocks controls, no dead click/touch target, no truncated card description, and no fake gameplay information.
- Check low-end mobile VFX budgets, reduced-motion settings, color-independent telegraphs and readable mixed-enemy density.
- Run existing deterministic Godot gameplay/build/save/input tests and real-device verification gates separately; visual approval **is not** a release approval.
- Record precise differences with GDD §7.2 and §25 and fix outdated label/text in the scene implementation rather than modifying gameplay to mimic old V5 prose.

### Source delivery / repository state

The source Art Bible v5 and Visual Production Handoff v5 were delivered in the project art conversation. Their binary files must be imported from that handoff before integration; **this repository documentation change does not claim to include the binaries**. The GDD records the creator's approval of the direction and provides this stable implementation contract.
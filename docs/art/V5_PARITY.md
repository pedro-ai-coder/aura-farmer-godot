> **Current update — 24 October 2026:** The creator explicitly approves 37 exact PNGs: eight V5 weapons, 28 V5 passives and Touch Grass Clean Cut v2. Clean Cut is the selected visual refinement recorded in GDD §26. All selected copies are hash-verified and promoted; 32 current items use live bindings, five future-only passive artworks remain unoffered. See `docs/art/CREATOR_ICON_APPROVAL_2026-10-24.md` and `docs/art/CLEAN_CUT_INTEGRATION_ACCEPTANCE.md`. Earlier zero-approval/blocked statements below are historical checkpoints. Original source isolation and all gameplay rules remain intact.

# Hero Spotlight V5 visual parity tracker

Baseline: `c73624d40a4a4323947d1cb5ad31f89ebd8bfe22`, 23 October 2026. No open PRs at audit start. Production build.json independently matched this commit.

Actual 56-page PDF inspected, including all 22 composition pages. Source SHA-256: `fd531f6a25244b03b034ccfca35e5f9d71639796e264e036656a68e56e59d781`. Historical labels reconciled using GDD §26.4. Full-screen references are not runtime assets.

## Scene matrix

| ID | V5 page | Target | Current implementation / capture | Gap | Asset / QA status | Next scope |
| --- | ---: | --- | --- | --- | --- | --- |
| 01 | 6 | Main Menu | `spotlight_home.gd`; [native evidence](evidence/v5-home/menu-1600.jpg) | Isolated illustrated logo and clean plate blocked | Partial; owner/device acceptance open | See [acceptance status](../V5_ACCEPTANCE_STATUS.md) |
| 02 | 8 | Hero Selection | `spotlight_home.gd`; [native evidence](evidence/v5-help/heroes-1280.jpg) | Expanded effect help and owner composition review | Partial; owner/device acceptance open | See [acceptance status](../V5_ACCEPTANCE_STATUS.md) |
| 03 | 10 | Gameplay HUD | `spotlight_hud.gd`; [native evidence](evidence/v5-hud/playing-1280.jpg) | Illustrated equipment masters blocked | Partial; owner/device acceptance open | See [acceptance status](../V5_ACCEPTANCE_STATUS.md) |
| 04 | 12 | Level-up | `spotlight_offer_card.gd` / `arcade_presentation.gd`; [native evidence](evidence/v5-cards/choice-915.jpg) | Live legal cards; isolated icons blocked | Partial; owner/device acceptance open | See [acceptance status](../V5_ACCEPTANCE_STATUS.md) |
| 05 | 14 | Legendary | `spotlight_offer_card.gd` / `arcade_presentation.gd`; [native evidence](evidence/v5-cards/legendary-1280.jpg) | Six legal offers; illustration pass remains | Partial; owner/device acceptance open | See [acceptance status](../V5_ACCEPTANCE_STATUS.md) |
| 06 | 16 | Pause | `spotlight_secondary.gd`; [native evidence](evidence/v5-secondary/paused-1280.jpg) | Owner comparison and physical input acceptance | Partial; owner/device acceptance open | See [acceptance status](../V5_ACCEPTANCE_STATUS.md) |
| 07 | 18 | Settings | `spotlight_secondary.gd`; [native evidence](evidence/v5-secondary/options-1280.jpg) | Master bus live; separate music/SFX controls remain | Partial; owner/device acceptance open | See [acceptance status](../V5_ACCEPTANCE_STATUS.md) |
| 08 | 20 | Victory | `spotlight_secondary.gd`; [native evidence](evidence/v5-secondary/won-1280.jpg) | Staged outcome; normal-health victory unproven | Partial; owner/device acceptance open | See [acceptance status](../V5_ACCEPTANCE_STATUS.md) |
| 09 | 22 | Defeat | `spotlight_secondary.gd`; [native evidence](evidence/v5-secondary/lost-1280.jpg) | Owner composition review | Partial; owner/device acceptance open | See [acceptance status](../V5_ACCEPTANCE_STATUS.md) |
| 10 | 24 | Boss Encounter | `spotlight_hud.gd`; [native evidence](evidence/v5-hud/boss-1280.jpg) | Staged boss; normal-health reachability blocked | Partial; owner/device acceptance open | See [acceptance status](../V5_ACCEPTANCE_STATUS.md) |
| 11 | 26 | Mobile Landscape | `floating_joystick.gd`; [native evidence](evidence/v5-review/mobile-915.jpg) | Native pointer emulation only; device acceptance open | Partial; owner/device acceptance open | See [acceptance status](../V5_ACCEPTANCE_STATUS.md) |
| 12 | 28 | Build Inspection | `spotlight_secondary.gd`; [native evidence](evidence/v5-secondary/build-1280.jpg) | Actual 3+5 slots; icon masters/effect detail remain | Partial; owner/device acceptance open | See [acceptance status](../V5_ACCEPTANCE_STATUS.md) |
| 13 | 30 | Sigma Flex | `solo_run.gd`; [native evidence](evidence/v5-hud/flex_sigma-1280.jpg) | Current mechanics captured; signature exports blocked | Partial; owner/device acceptance open | See [acceptance status](../V5_ACCEPTANCE_STATUS.md) |
| 14 | 32 | Cool Kid / Alpha Flex | `solo_run.gd`; [native evidence](evidence/v5-hud/flex_alpha-1280.jpg) | Also flex_cool-1280.jpg; signature exports blocked | Partial; owner/device acceptance open | See [acceptance status](../V5_ACCEPTANCE_STATUS.md) |
| 15 | 34 | Weapons Gallery | `weapon_visuals.gd`; No equivalent capture | Nine isolated PNG/SVG masters absent; no equivalent gallery capture | Partial; owner/device acceptance open | See [acceptance status](../V5_ACCEPTANCE_STATUS.md) |
| 16 | 36 | Passives Gallery | `solo_passive_rules.gd`; No equivalent capture | 28 icon pairs absent; preserve 23 offered subset | Partial; owner/device acceptance open | See [acceptance status](../V5_ACCEPTANCE_STATUS.md) |
| 17 | 38 | Enemy Bestiary | `approved_visuals.gd`; No equivalent capture | Original atlas in runtime; no equivalent bestiary composition capture | Partial; owner/device acceptance open | See [acceptance status](../V5_ACCEPTANCE_STATUS.md) |
| 18 | 40 | Pickups | `recovery_rules.gd`; [native evidence](evidence/v5-hud/station-1280.jpg) | Recovery contracts live; isolated exports blocked | Partial; owner/device acceptance open | See [acceptance status](../V5_ACCEPTANCE_STATUS.md) |
| 19 | 42 | Wave Transition | `spotlight_hud.gd`; [native evidence](evidence/v5-hud/wave-1280.jpg) | Simulation-bound banner; owner review open | Partial; owner/device acceptance open | See [acceptance status](../V5_ACCEPTANCE_STATUS.md) |
| 20 | 44 | Full Hater Mode | `spotlight_hud.gd`; [native evidence](evidence/v5-hud/berserk-1280.jpg) | Recoverable Berserk unchanged; dedicated art blocked | Partial; owner/device acceptance open | See [acceptance status](../V5_ACCEPTANCE_STATUS.md) |
| 21 | 46 | Quit Confirmation | `spotlight_secondary.gd`; [native evidence](evidence/v5-secondary/confirm_exit-1280.jpg) | Paused STAY/QUIT; owner review open | Partial; owner/device acceptance open | See [acceptance status](../V5_ACCEPTANCE_STATUS.md) |
| 22 | 48 | Safe Spot | `recovery_rules.gd`; [native evidence](evidence/v5-hud/station-1280.jpg) | Charge/cooldown live; final isolated art remains | Partial; owner/device acceptance open | See [acceptance status](../V5_ACCEPTANCE_STATUS.md) |

## Evidence limits

Baseline native Compatibility captures use Mesa llvmpipe software rendering, 1280×720; committed review copies are 960×540 JPEGs. These are staged real game states, not normal survival or physical-device/FPS evidence. `character` is the old combined home, not a completed hero selection screen. Reused pause/station captures document existing shared implementations and do not imply separate scenes exist. Missing gallery/Flex/wave/quit captures remain explicit.

All 33 baseline Godot phases and Node platform tests passed after complete asset download/import. The first attempt overlapped restoration and failed on unavailable imported textures; it is not counted as a product regression.

## Asset handoff blockers

Only the attached PDF and 19 pinned original PNG masters/atlases were available. No V5 handoff ZIP, isolated logo, clean background plate, 37 PNG/SVG icon pairs or dedicated Flex animation exports are present. Preserve original identities. Never crop the PDF into shipping art. Continue live layout/font/navigation work independently.

## Milestones

- G3.0 audit: baseline source, actual compositions, asset inventory and initial captures recorded here.
- G3.1 integrated (#47): licensed Inter resources, semantic V5 theme, reusable live primitives, accessible states.
- G3.2 integrated (#48): independent PLAY / HEROES / SETTINGS home and dedicated three-hero screen.
- Remaining phases: follow `../WORK_HERO_SPOTLIGHT_V5_PLAN.md`; no balance changes implicit.

## Balance workstream

The existing seed-451 normal-health runs did not reach Big Hater. Preserve those observations in `../FLEX_V2_VALIDATION.md`. Investigate controller strategy/aim, damage sources, recovery routing, XP collection and event overlap separately; numeric changes require a measured GDD proposal. Visual PRs do not change HP/damage/XP/drops.

## Additional baseline viewports

Real staged captures also recorded at 1600×900, 915×412 and 390×844. Useful examples: [1600 menu](evidence/v5-baseline/menu-1600.jpg), [915 choices](evidence/v5-baseline/choice-915.jpg), [portrait legendary](evidence/v5-baseline/legendary-390.jpg). Review copies retain their aspect ratio and are scaled to fit 960×540; full-resolution originals remain scratch QA intermediates. Native rendering with desktop touch layout enabled is not touch-device acceptance.

## G3.1 — shared typography and components

Licensed Inter 500/600/900 resources and Display optical sizing are bundled with OFL/source hashes. Shared palette/action/card/focus styles now follow V5; live component factories provide actions, ink panels, status plates, icon slots and modal shells. Action hit areas are at least 64 logical pixels (48 physical at the minimum 0.75 scale). Existing legal card selection and data remain authoritative. This milestone does not supply blocked illustrations, independent logo or the final scene layouts. Native theme comparison evidence is recorded under `evidence/v5-theme`; physical-device and owner artistic acceptance remain open.

Native focus review reproduced a compact-card bug: ensuring a tall selected card was visible scrolled its name/rarity away. Compact landscape cards now fit available height when possible and oversized selections align to their top. [Selected/focused compact capture](evidence/v5-theme/choice-915.jpg) records the corrected state. Typography/action states are compared at 1280, 1600, 1920 and 915 widths; illustration and full composition remain partial.

## G3.2 — live home and hero selection

[Home 1600](evidence/v5-home/menu-1600.jpg) and [hero selection 1600](evidence/v5-home/character-1600.jpg) compare actual Godot against V5 pages 6/8. Native captures also cover [compact landscape](evidence/v5-home/menu-915.jpg) and [portrait fallback](evidence/v5-home/menu-390.jpg). Original approved Sigma art is separate from every button/text node. No baked old menu composite is used. The live Inter heading is an interim text treatment, **not** a newly approved illustrated logo. Background uses the unchanged approved Ruin Alley master with a dark UI wash, **not** a claimed clean V5 plate export.

The three dominant PLAY / HEROES / SETTINGS destinations are functional. Hero cards use authentic portraits and authoritative role/starter/Flex definitions; six later heroes are not falsely selectable. Responsive containers keep START/BACK outside card scrolling, retain focus on visible controls and preserve explicit selection before start. Current source token palette is shared with all other scenes; the selected rim is gold and keyboard focus is a separate sky outline. Portrait fallback prioritizes controls and hero selection rather than squeezing the home illustration.

Reproduced old combined home/selection failures before code changes. Six viewport regressions caught retained-grid minimum width pushing START outside 640/390-width layouts; clearing the old minimum fixes it. Enter on focused navigation is delegated to GUI rather than forcibly starting a run. The local 35-phase suite passes. Actual native renders are visual comparisons, not physical touch/browser acceptance or owner sign-off.

## G3.3 — compact HUD and simulation-bound transition feedback

Replaces the broad cream HUD chassis with distinct HP, XP/level and Aura plates plus shield/wave/clock status. READY styling updates only on state change, not by rebuilding styles every frame. Boss information shows actual HP and the canonical 120-second Berserk countdown. Native comparison found a centered boss plate covering the actual initial boss silhouette; it now moves aside (or above the action footer on narrow layouts) when projected bounds intersect. No boss position or camera physics is changed.

[Gameplay](evidence/v5-hud/playing-1280.jpg), [boss](evidence/v5-hud/boss-1280.jpg), [wave](evidence/v5-hud/wave-1280.jpg), [Berserk](evidence/v5-hud/berserk-1280.jpg), [Sigma Verdict](evidence/v5-hud/flex_sigma-1280.jpg), [Cool ENTER](evidence/v5-hud/flex_cool-1280.jpg), [Alpha GIGA](evidence/v5-hud/flex_alpha-1280.jpg) and [portrait HUD](evidence/v5-hud/playing-390.jpg) are staged real native captures. The Flex fixtures use explicit test setup and ordinary combat/schedulers; they are not survival/balance evidence. Runtime marks, beats, finishers and original poses are visible; dedicated V5 signature artwork remains missing. The existing world-space Snack/Magnet/Safe Spot drawings are still interim and must not be called final V5 exports.

Transition emphasis follows actual wave/berserk state and simulation time, clears on restart and does not pause the game. Optional friendly banners are suppressed during hostile warnings/nearby hazards and shift away from the boss silhouette. Regression checks cover timing, repeated refresh, pause, danger priority and cleanup; the complete 36-phase suite and Node platform checks are run for the milestone. Actual browser/device/FPS/owner acceptance remains separate.

## G3.4 — secondary flow continuity

The actual [pause](evidence/v5-secondary/paused-1280.jpg), [settings](evidence/v5-secondary/options-1280.jpg), [build](evidence/v5-secondary/build-1280.jpg), [victory](evidence/v5-secondary/won-1280.jpg), [defeat](evidence/v5-secondary/lost-1280.jpg) and [quit confirmation](evidence/v5-secondary/confirm_exit-915.jpg) now share the V5 font/palette/actions. Pause is one compact navigation shell; Build is a separate paused inspection; in-run Settings returns to pause and hides profile import/export so it cannot accidentally abandon the run. Results use approved portraits and actual time/level/kills/equipment/damage/healing/protection/Flex values. The staged result captures are intentionally test outcomes, not evidence of ordinary boss victory.

A real master-volume slider controls the audio bus and persists an optional clamped `masterVolume` preference in compatible v2 profiles; old/corrupt profiles default safely to full gain. Debounced saving avoids per-pixel disk writes. Keyboard focus includes sliders/text fields as well as buttons. Audible playback, separate music/SFX buses and exact V5 settings tabs are not claimed. Current available audio routing is a single master bus.

New tests reproduce the old combined pause/build/settings gap and cover settings return/clock freeze, actual volume preference, 3+5 inspection, STAY, resume, truthful loss statistics, four responsive sizes, replay and profile normalization. The full 37-phase suite plus Node platform tests pass. Layouts are native staged comparisons only; actual browser/physical-device and owner visual acceptance remain open.

## Current evidence index

The matrix above supersedes the initial baseline pointers. PRs #46, #47, #48, #50 and #51 are integrated. See [acceptance status](../V5_ACCEPTANCE_STATUS.md) for measured survival/performance, component mapping and remaining gates. No row implies owner visual acceptance. The historical baseline limitations below remain applicable to baseline captures only.

## G3.6 — live offer-card composition

The reattached PDF SHA-256 matches the audited source exactly. All 22 composition thumbnails were reviewed again, with enlarged pages 12/14 guiding this change. The additional conceptual panel SHA-256 is `600d5f85b07d8d03e0e33ab9af8f41b96801efa98f4962ae8456125e0a990603`; its alternate identities, labels and mechanics are not authoritative over the GDD or canonical V5 PDF.

Before: small inline glyph beside rarity/level, weak category separation, and no dedicated rarity header or icon surface. Now: reusable live `SpotlightOfferCard`, explicit rarity band, reserved icon surface, name/category/effect/comparison hierarchy, textual selection feedback and gold modal rim. Three normal cards and six legendary cards remain the existing legal data, ordering and RNG. No screenshots are runtime UI and no new icon master is introduced. Existing glyphs remain visibly interim pending #49.

Actual [normal comparison](evidence/v5-cards/compare-choice.jpg) and [legendary comparison](evidence/v5-cards/compare-legendary.jpg) pair PDF reference crops with native Godot. These reference crops exist only inside excluded QA evidence, never standalone shipping assets. The current GDD overrides historical labels/values. Normal cards use a vertical icon hierarchy on desktop/portrait and a compact row at 915×412 so effects/current-to-new comparison remain visible beside the fixed Confirm action. Portrait uses scrolling with selection repeated in the fixed header. Captures: [desktop](evidence/v5-cards/choice-1280.jpg), [compact](evidence/v5-cards/choice-915.jpg), [portrait](evidence/v5-cards/choice-390.jpg), [portrait legendary](evidence/v5-cards/legendary-390.jpg).

Regression coverage found and fixed long-description overlap and initially unmeasured wrapped-label heights when the six-card screen first opens. The local official Godot 4.7.2 suite passes all 38 phases, including longest catalog descriptions at desktop/compact card widths and focused two-step keyboard confirmation. Native Compatibility screenshots use Mesa llvmpipe and staged real states; no physical-device/FPS or owner visual acceptance is implied. Missing illustrations, final blur/material polish and reference ordering differences remain explicit; runtime offer order is deliberately preserved.

## G3.7 — current signature explanations

The three original hero portraits, starter names, roles, signature names and authoritative active durations are preserved. Each live card now explains its approved GDD §7.2 signature without requiring hover: Sigma's marked-target three-attack Verdict, Cool Kid's aimed beats/ENTER and remaining projectile/hazard danger, Alpha's shield/slams/absorbed-damage countershock. The obsolete Cool Kid catalog Rampage description is removed. Tooltips retain the common 100-Aura / minimum-30-second activation rules. No combat, save or simulation values changed.

Cards retain fixed START/BACK actions, and their text is scrollable on compact viewports. Actual native evidence: [desktop](evidence/v5-help/heroes-1280.jpg), [compact top](evidence/v5-help/heroes-915.jpg), [compact details after real ScrollContainer navigation](evidence/v5-help/heroes-detail-915.jpg), [portrait](evidence/v5-help/heroes-390.jpg). Capture reproduction: `tests/capture_review.gd -- 915 412 OUTPUT --hero-help`. Dedicated signature exports and owner artistic/physical-device acceptance remain open. Additional prior-milestone captures at 1600×900: [normal](evidence/v5-cards/choice-1600.jpg), [legendary](evidence/v5-cards/legendary-1600.jpg).

The local navigation regression exercises all three real starter selections across six viewports and checks that catalog help is visible in the live labels. The complete 39-phase local Godot validation suite passes after incorporating upstream #55/#56, which independently expanded survival-policy QA. Do not replace that new survival evidence with the historical eight-run avoidance result.

## Private Web Alpha gameplay audit

No new artwork supplied or integrated in this correction. Original 19 masters remain hash-verified; PDF/concept references are unchanged and standalone #49 exports are still absent. [Controlled actual Tank shield captures](../WEB_ALPHA_ACCEPTANCE.md#a1a3-correction-legendary-tank-support-shields) verify the real HUD after §8.2 formula correction, without implying artistic acceptance or a normal-health win.


## G4.1 Clean Cut source review

All 37 canonical candidates and 83 manifest files were audited, including actual Godot SVG decoding and source composites at 32/64/256px on navy/cream. See `docs/art/CLEAN_CUT_ICON_REVIEW.md` and per-ID audit JSON. SVG font differences, narrow margins and compact identity families are recorded. Zero individual approvals or runtime promotions; the 23-passive subset and candidate export isolation remain unchanged. Next: reusable approved icon pipeline and live fallback bindings; activate only exact creator-approved hashes.


## G4.1 approved icon pipeline and safe live bindings

The source audit is integrated through #64. A separate approval ledger, immutable hashed PNG promotion, category-aware cached registry and automatic actual-PCK export guard now prepare live offer/legendary/replacement, build and HUD bindings. Eleven Python regressions and a Godot registry phase supplement the existing suite. All 40 actual before/after fallback captures are pixel-identical; compact viewport one-pixel rounding is recorded. See `docs/art/APPROVED_ICON_PIPELINE.md`. Counts remain 37 audited, 0 creator-approved, 0 promoted, 0 illustrated items accepted in live UI. Creator decisions, approved-icon visual/performance evidence and device/browser gates remain pending; gameplay/23-passive scope are unchanged.

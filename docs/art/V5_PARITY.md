# Hero Spotlight V5 visual parity tracker

Baseline: `c73624d40a4a4323947d1cb5ad31f89ebd8bfe22`, 23 October 2026. No open PRs at audit start. Production build.json independently matched this commit.

Actual 56-page PDF inspected, including all 22 composition pages. Source SHA-256: `fd531f6a25244b03b034ccfca35e5f9d71639796e264e036656a68e56e59d781`. Historical labels reconciled using GDD §26.4. Full-screen references are not runtime assets.

## Scene matrix

| ID | V5 page | Target | Current implementation / capture | Gap | Asset / QA status | Next scope |
| --- | ---: | --- | --- | --- | --- | --- |
| 01 | 6 | Main Menu | `arcade_presentation.gd` / `solo_run.gd`; [native baseline](evidence/v5-baseline/menu.jpg) | G3.2: live hero-left / navy-actions-right shell; isolated illustrated wordmark and clean plate still blocked | Partial; owner/device acceptance open | G3.1 theme, then phased screen work |
| 02 | 8 | Hero Selection | `arcade_presentation.gd` / `solo_run.gd`; [native baseline](evidence/v5-baseline/character.jpg) | G3.2: separate responsive three-card selection; current role/starter/Flex data and explicit START; detailed effect help remains partial | Partial; owner/device acceptance open | G3.1 theme, then phased screen work |
| 03 | 10 | Gameplay HUD | `arcade_presentation.gd` / `solo_run.gd`; [native baseline](evidence/v5-baseline/playing.jpg) | G3.3: independent compact navy status plates; adaptive boss plate and canonical countdown; illustrated slot masters still blocked | Partial; owner/device acceptance open | G3.1 theme, then phased screen work |
| 04 | 12 | Level-up | `arcade_presentation.gd` / `solo_run.gd`; [native baseline](evidence/v5-baseline/choice.jpg) | Glyphs instead of signed isolated icons; weak hierarchy | Partial; owner/device acceptance open | G3.1 theme, then phased screen work |
| 05 | 14 | Legendary | `arcade_presentation.gd` / `solo_run.gd`; [native baseline](evidence/v5-baseline/legendary.jpg) | Six legal choices present; illustration assets missing | Partial; owner/device acceptance open | G3.1 theme, then phased screen work |
| 06 | 16 | Pause | `arcade_presentation.gd` / `solo_run.gd`; [native baseline](evidence/v5-baseline/paused.jpg) | Build/settings combined rather than compact pause destinations | Partial; owner/device acceptance open | G3.1 theme, then phased screen work |
| 07 | 18 | Settings | `arcade_presentation.gd` / `solo_run.gd`; [native baseline](evidence/v5-baseline/options.jpg) | Live toggles, no shared navy shell | Partial; owner/device acceptance open | G3.1 theme, then phased screen work |
| 08 | 20 | Victory | `arcade_presentation.gd` / `solo_run.gd`; [native baseline](evidence/v5-baseline/won.jpg) | Text results without hero-led composition | Partial; owner/device acceptance open | G3.1 theme, then phased screen work |
| 09 | 22 | Defeat | `arcade_presentation.gd` / `solo_run.gd`; [native baseline](evidence/v5-baseline/lost.jpg) | Text results without hero-led composition | Partial; owner/device acceptance open | G3.1 theme, then phased screen work |
| 10 | 24 | Boss Encounter | `arcade_presentation.gd` / `solo_run.gd`; [native baseline](evidence/v5-baseline/boss.jpg) | Real boss/clock, presentation needs compact encounter plates | Partial; owner/device acceptance open | G3.1 theme, then phased screen work |
| 11 | 26 | Mobile Landscape | `arcade_presentation.gd` / `solo_run.gd`; No equivalent capture yet | Emulation only; physical devices absent | Partial; owner/device acceptance open | G3.1 theme, then phased screen work |
| 12 | 28 | Build Inspection | `arcade_presentation.gd` / `solo_run.gd`; [native baseline](evidence/v5-baseline/paused.jpg) | 3+5 slots implemented, effect details incomplete | Partial; owner/device acceptance open | G3.1 theme, then phased screen work |
| 13 | 30 | Sigma Flex | `arcade_presentation.gd` / `solo_run.gd`; No equivalent capture yet | Mechanics implemented; dedicated approved animation exports missing | Partial; owner/device acceptance open | G3.1 theme, then phased screen work |
| 14 | 32 | Cool Kid / Alpha Flex | `arcade_presentation.gd` / `solo_run.gd`; No equivalent capture yet | Mechanics implemented; signature exports missing | Partial; owner/device acceptance open | G3.1 theme, then phased screen work |
| 15 | 34 | Weapons Gallery | `arcade_presentation.gd` / `solo_run.gd`; No equivalent capture yet | No illustrated isolated exports available | Partial; owner/device acceptance open | G3.1 theme, then phased screen work |
| 16 | 36 | Passives Gallery | `arcade_presentation.gd` / `solo_run.gd`; No equivalent capture yet | 28 icons absent; only 23 passives offered | Partial; owner/device acceptance open | G3.1 theme, then phased screen work |
| 17 | 38 | Enemy Bestiary | `arcade_presentation.gd` / `solo_run.gd`; No equivalent capture yet | Existing approved runtime atlas; gallery absent | Partial; owner/device acceptance open | G3.1 theme, then phased screen work |
| 18 | 40 | Pickups | `arcade_presentation.gd` / `solo_run.gd`; [native baseline](evidence/v5-baseline/station.jpg) | Recovery works; approved isolated exports missing | Partial; owner/device acceptance open | G3.1 theme, then phased screen work |
| 19 | 42 | Wave Transition | `arcade_presentation.gd` / `solo_run.gd`; No equivalent capture yet | G3.3: active-clock named wave banner; suppressed by enemy warnings | Partial; owner/device acceptance open | G3.1 theme, then phased screen work |
| 20 | 44 | Full Hater Mode | `arcade_presentation.gd` / `solo_run.gd`; [native baseline](evidence/v5-baseline/berserk.jpg) | G3.3: brief active-clock Full Hater banner with danger-priority guard; dedicated exports remain blocked | Partial; owner/device acceptance open | G3.1 theme, then phased screen work |
| 21 | 46 | Quit Confirmation | `arcade_presentation.gd` / `solo_run.gd`; No equivalent capture yet | Functional confirmation; presentation differs | Partial; owner/device acceptance open | G3.1 theme, then phased screen work |
| 22 | 48 | Safe Spot | `arcade_presentation.gd` / `solo_run.gd`; [native baseline](evidence/v5-baseline/station.jpg) | Charge/cooldown works; status visual differs | Partial; owner/device acceptance open | G3.1 theme, then phased screen work |

## Evidence limits

Baseline native Compatibility captures use Mesa llvmpipe software rendering, 1280×720; committed review copies are 960×540 JPEGs. These are staged real game states, not normal survival or physical-device/FPS evidence. `character` is the old combined home, not a completed hero selection screen. Reused pause/station captures document existing shared implementations and do not imply separate scenes exist. Missing gallery/Flex/wave/quit captures remain explicit.

All 33 baseline Godot phases and Node platform tests passed after complete asset download/import. The first attempt overlapped restoration and failed on unavailable imported textures; it is not counted as a product regression.

## Asset handoff blockers

Only the attached PDF and 19 pinned original PNG masters/atlases were available. No V5 handoff ZIP, isolated logo, clean background plate, 37 PNG/SVG icon pairs or dedicated Flex animation exports are present. Preserve original identities. Never crop the PDF into shipping art. Continue live layout/font/navigation work independently.

## Milestones

- G3.0 audit: baseline source, actual compositions, asset inventory and initial captures recorded here.
- G3.1 next: licensed Inter resources, semantic V5 theme, reusable live primitives, accessible states.
- G3.2 next: independent PLAY / HEROES / SETTINGS home and dedicated three-hero screen.
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

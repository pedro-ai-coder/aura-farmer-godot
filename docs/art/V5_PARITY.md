# Hero Spotlight V5 visual parity tracker

Baseline: `c73624d40a4a4323947d1cb5ad31f89ebd8bfe22`, 23 October 2026. No open PRs at audit start. Production build.json independently matched this commit.

Actual 56-page PDF inspected, including all 22 composition pages. Source SHA-256: `fd531f6a25244b03b034ccfca35e5f9d71639796e264e036656a68e56e59d781`. Historical labels reconciled using GDD §26.4. Full-screen references are not runtime assets.

## Scene matrix

| ID | V5 page | Target | Current implementation / capture | Gap | Asset / QA status | Next scope |
| --- | ---: | --- | --- | --- | --- | --- |
| 01 | 6 | Main Menu | `arcade_presentation.gd` / `solo_run.gd`; [native baseline](evidence/v5-baseline/menu.jpg) | Baked menu composite dominates; home and hero selection combined | Partial; owner/device acceptance open | G3.1 theme, then phased screen work |
| 02 | 8 | Hero Selection | `arcade_presentation.gd` / `solo_run.gd`; [native baseline](evidence/v5-baseline/character.jpg) | No dedicated destination; tiny portraits share home | Partial; owner/device acceptance open | G3.1 theme, then phased screen work |
| 03 | 10 | Gameplay HUD | `arcade_presentation.gd` / `solo_run.gd`; [native baseline](evidence/v5-baseline/playing.jpg) | Large cream bar instead of compact navy plates | Partial; owner/device acceptance open | G3.1 theme, then phased screen work |
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
| 19 | 42 | Wave Transition | `arcade_presentation.gd` / `solo_run.gd`; No equivalent capture yet | No authored simulation-bound transition banner | Partial; owner/device acceptance open | G3.1 theme, then phased screen work |
| 20 | 44 | Full Hater Mode | `arcade_presentation.gd` / `solo_run.gd`; [native baseline](evidence/v5-baseline/berserk.jpg) | Mechanics implemented; banner hierarchy differs | Partial; owner/device acceptance open | G3.1 theme, then phased screen work |
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

# Recovery and presentation acceptance — 22 October 2026

## Implemented and integrated

| PR | Scope | Verification |
| --- | --- | --- |
| [29](https://github.com/pedro-ai-coder/aura-farmer-godot/pull/29) | Original static-cover frame 14, foot-depth rendering, responsive bounded camera | Six viewport camera tests, exact collider/atlas checks |
| [30](https://github.com/pedro-ai-coder/aura-farmer-godot/pull/30) | Approved Street Snack, Aura Magnet, Safe Spot | Seeded generator, rate/cap/collection/healing/pause/restart/boss regressions |
| [32](https://github.com/pedro-ai-coder/aura-farmer-godot/pull/32) | Cartoon Arcade menu, hero selection, cards, HUD, settings/results/save panels | Real desktop WebGL2/OpenGL captures, UI tests |
| [33](https://github.com/pedro-ai-coder/aura-farmer-godot/pull/33) | Mobile safe areas, targets, scrolling, touch/focus lifecycle, browser gestures, cache-safe output | Six viewport tests; actual Chromium touch fullscreen/orientation, joystick/release/pause/resize; Node denied/unavailable cases |
| [35](https://github.com/pedro-ai-coder/aura-farmer-godot/pull/35) | Explicit seeded integer draw dispatch | JavaScript integer parity, mixed draw stream, deterministic offers/enemy selection; 30-phase suite |
| [34](https://github.com/pedro-ai-coder/aura-farmer-godot/pull/34) | Authored hero/enemy playback, fixed sprite scales, edge mattes, original terminal sprite | New animation tests; complete 30-phase suite, Web export and real browser smoke |

PR 31 was closed without merging after a publication-tree error; PR 32 is the verified replacement. No incomplete tree reached main.

Integrated implementation PRs passed required Godot CI and Vercel preview build checks before integration; PR 35 passed the 30-phase suite and hosted checks before integration as `622d374e673fdb1d08e38436a8a96d51bbc70f3b`. Owner artistic acceptance is deferred. Original Phaser tracked files and approved source PNGs are unchanged. Appendix C P4–P8 remain unimplemented proposals; the mission's P4 verification is distinct from those product proposals.

## Recovery evidence

Mulberry32 matches eight JavaScript reference values within 1e-15. Equivalent 10,000-kill RNG samples produce exactly 518 snacks / 210 magnets for normal enemies and 1,999 / 804 for elites. This verifies deterministic rates, not a guarantee for an individual short run. Special drops remain capped at five per kind and recycle only their own oldest item. Snack heals 18% maximum HP, magnet collects existing XP exactly once, and Safe Spot charges for two uninterrupted active seconds for 25% healing with 90 active seconds of cooldown. Existing approved support modifiers are preserved. Full health, leaving the station, pause, restart, boss transitions and non-eligible kills are covered.

## Ordinary-health run observations

`tests/review_unprotected_run.gd` supplies only movement, legal upgrade selections and manual Flex input. It does not grant XP, items, healing, time jumps, invulnerability or a forced final hit. Its audit override calls the original damage function. The final runner isolates profile persistence. These are accelerated autonomous simulations, not human or rendered full-run acceptance.

The acceptance repetition exposed and corrected a separate seeded-integer bug in PR 35: unqualified `randf()` inside the integer wrapper resolved to Godot's global random function. Explicit `self.randf()` restores one deterministic shared stream for offers and spawns. Earlier observations are therefore retained only as pre-fix history; their seeds did not describe the full random sequence.

After the fix, a normal-health Sigma run with **seed 454** defeated Big Hater through normal combat at **975.15 active seconds (16:15)**, level 25, 1,078 kills, 16 manual Flex activations and **20.43 HP remaining**. Minimum post-step HP was 15.10, with 721.01 recorded healing, 56 snacks, 19 magnets and two Safe Spot uses. No final damage grant was used. A fresh-process repetition produced exactly the same complete result JSON, including equipment, timers, recovery counts and final HP. A sweep of seeds 452–456 produced one win and four defeats; every result is retained in the raw logs. This is a successful autonomous full run, not a human playtest or a general balance pass.

| Post-fix controller | Hero / seed | Result | Active time | Level | Kills | Healing |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| Auto aim / original legal picker | Sigma / 451 | Defeat | 752.10 s | 25 | 828 | 568.29 |
| Auto aim / original legal picker | Cool Kid / 451 | Defeat | 634.53 s | 23 | 625 | 825.85 |
| Auto aim / original legal picker | Alpha Chad / 451 | Defeat | 358.80 s | 14 | 351 | 123.07 |
| Event mouse aim / starter legendary priority | Sigma / 452 | Defeat | 885.72 s | 25 | 1,040 | 868.35 |
| Event mouse aim / starter legendary priority | Sigma / 453 | Defeat | 762.77 s | 25 | 847 | 614.07 |
| Event mouse aim / starter legendary priority | Sigma / 454 | Victory | 975.15 s | 25 | 1,078 | 721.01 |
| Event mouse aim / starter legendary priority | Sigma / 455 | Defeat | 569.37 s | 21 | 576 | 162.88 |
| Event mouse aim / starter legendary priority | Sigma / 456 | Defeat | 741.67 s | 25 | 814 | 513.23 |

The current runner uses legal mouse-aim input for ranged heroes against visible event/boss targets and prioritizes the starter at the legendary choice. These controller changes are separate from production balance. The three-hero seed-451 observations used its preceding auto-aim picker. Recovery is demonstrably available in ordinary-health play, but **all-three-starter balance acceptance remains open**. The protected continuous fixture separately verifies all waves, legal equipment, drops, one legendary and terminal/restart state; its forced survival and final resolution are excluded from balance evidence.

A pre-fix Sigma observation also won at 988.92 seconds with 13.94 HP; that log is retained and clearly labeled pre-fix. It is superseded by the post-fix seed-454 result above.

## Rendered load measurement

Godot 4.7.2 Compatibility renderer, Mesa 25.2.8 llvmpipe (LLVM 20.1.2), Xvfb. `tests/review_render_performance.gd` keeps 300 drawn enemies and 150 drawn player projectiles stable, warms 40 frames, then measures 200 actual rendered frame intervals. Motion poses advance; simulation and AI are deliberately excluded to keep counts stable. This is a **render-only software-host benchmark**, not total-game performance. VSync control is unsupported on this driver. Shared-host load varies; results below are observations, not device guarantees.

| Viewport | Mean frame | Median | P95 | Mean FPS |
| --- | ---: | ---: | ---: | ---: |
| 1280×720 | 38.73 ms | 37.96 ms | 52.35 ms | 25.82 |
| 915×412 | 34.42 ms | 34.35 ms | 46.97 ms | 29.06 |

Earlier samples ranged from 18.09 FPS desktop to 32.10 FPS landscape mobile size on this software host. The reference desktop 60 FPS / physical-mobile 30 FPS objectives remain **unverified**, and the desktop software stress sample falls below 60 FPS. Headless simulation elapsed time is not presented as FPS.

## Screenshot comparison

The evidence package contains an HTML comparison gallery and original PNGs: Phaser and Godot at 1280×720 for home, character selection, early gameplay, cover, recovery, Safe Spot, level-up, legendary selection, dense combat, pause, boss, victory and defeat; additional Godot landscape-touch and portrait layouts. Further native captures were exercised at 1920×1080 and 844×390. Fixtures are staged comparable moments, not identical RNG runs or human gameplay recordings.

Phaser captures use its unchanged local Vite app. The existing test pattern exposes BrowserApp through temporary HTTP response interception only; it does not edit source. Godot captures are actual rendered viewport images, not design mockups. Both reuse the same approved backdrop, hero/enemy atlases, static crates, recovery symbols, catalog symbols and paper/ink/gold/teal palette. Matching early-world captures confirm aligned crate positions and Safe Spot, and fixed hero atlas scale now preserves authored proportions. Godot intentionally keeps the original main-menu logo artwork, while Phaser home uses its text-led panel; these compositions are not pixel-identical.

Godot uses its fallback UI font and Phaser uses its browser typography; typographic identity is not claimed. Godot retains per-actor health bars and organizes Aura/build actions differently. The reusable theme, rarity cards, touch targets and scrollable portrait panels improve readability, but final artistic acceptance remains with the owner. No 85/100 or complete-parity score is asserted.

## Deployment and remaining limits

The Vercel dashboard initially showed production at PR 32 (`2feef32`) while later main merges had no deployment. It displayed a GitHub-outage/delayed-automatic-deployment notice. The existing authenticated browser session allowed normal **Create Deployment → main → Deploy to Production**, without changing permissions or protection. The resulting production deployment is **Ready / Current**, source `622d374e673fdb1d08e38436a8a96d51bbc70f3b` (PR 35 merge), deployment `2pkrM3BzVUaLWUrYmK1gM658pb5R`.

The public `/build.json` returns HTTP 200 with that exact commit, Godot 4.7.2 and executable `game-622d374e673f`. The landing document references the same versioned payload. Ten published files (67,466,066 bytes) were fetched through verified HTTPS, with lengths, SHA-256, cache and content-type recorded in the evidence manifest. This verifies production revision and delivery. Team-scoped connector inspection still returns 403, but it did not block the authenticated dashboard workflow.

Direct runtime checks have environment limits: the cloud browser reports missing WebGL2; local Chromium direct HTTPS reaches an untrusted proxy-certificate error. Certificate validation was not disabled. The unmodified published payload is therefore additionally exercised through a local HTTP fixture in the working Chromium software-WebGL2 environment. The exact deployed payload passed Play, joystick/release, fullscreen/orientation success, pause, fullscreen exit and portrait resize with no page errors or horizontal overflow. That distinguishes deployed-byte execution from a direct end-to-end browser run on the public domain.

Actual Chromium software WebGL2 passed Play/pause, touch joystick/release, fullscreen/orientation success, fullscreen exit and 915×412→390×844 resize without page errors or horizontal overflow. Browser permission denial and missing APIs are isolated Node tests. Physical Android/iOS, iOS safe-area/notch behavior, native builds/signing, reference-device FPS, touch ergonomics and owner visual acceptance remain unverified. No paid service, new artwork, native release or canonical GDD edit was introduced.

## Reproduction

- `bash scripts/validate.sh` — complete automated suite (requires Godot 4.7.2 and verified assets).
- `godot --headless --path . --script res://tests/review_unprotected_run.gd -- 0 454` — ordinary-health Sigma observation; omit arguments for three starters. Add `--audit` after hero/seed for damage trace. A defeat is an observed result, not a test pass.
- `godot --path . --script res://tests/review_render_performance.gd -- 1280 720 /absolute/existing/output` — actual graphical render-load observation; requires a working display/GL context.
- `godot --path . --script res://tests/capture_review.gd -- 1280 720 /absolute/output` — staged actual viewport screenshots.
- `bash scripts/build_web.sh` — hash-verified official Web export; versioned payload names and build.json identify the built commit. Import/export script errors fail the build even if Godot exits zero.

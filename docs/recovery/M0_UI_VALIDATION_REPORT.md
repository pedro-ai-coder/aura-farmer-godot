# Clean Cut recovery — implementation and validation

> Historical UI checkpoint. The [later combat recovery report](COMBAT_RECOVERY_REPORT.md) supersedes the open R12 discrepancy and records current CI and Web blockers. Images, timings and survival results below apply only to the sources identified here.

## Problem and behavior

Secondary navigation previously returned to the hidden/legacy presentation while primary screens used Clean Cut. Full skin refreshes also recreated styles every frame, and a naive layout cache would let the native presenter overwrite live skin controls. The recovery retains all original actions and data, adds eight secondary destinations, tracks native presentation revisions, caches immutable styles, and refreshes layout only when represented state or interaction state changes.

Two visible data defects were also corrected: the XP SVG contained a sample blue fill even at zero XP, and the boss renderer used an obsolete 18-minute Berserk threshold. XP now masks the sample segment and paints actual progress; boss artwork uses `SoloClock.BERSERK_AT`. No artwork bytes, simulation damage, cadence, drops, equipment limits or clocks changed.

## Source identity

- Main/GDD V3: `9d1b44f7c5ec9ea62382b0e83161ee7e5295aa1f` (PR #75 merged).
- Original PR #73: `9f15790dab544db24edd31101faeae2d0e3f1455`.
- Native baseline after main merge, before recovery code: local `7768e1c9cf39c9896a232b87ca0b9c1ca714ed47`.
- Initial recovery runtime/benchmark: remote `12d2f4de2826118850c453e66896ff6e9da39a37`, tree `c95cdccda4ffdb8655d18d540b2f2021fd6d2545`.
- Final runtime: remote `c30bb05bf612aa6075019feebef1fb8898950172`, tree `606ba810c7771f8f867bf23ae4da18aa76a0e4de`; equivalent local commit `5f4c46bdb520dbe067da56896f17599152295fa2`.
- Evidence/document-only commits may follow without changing the runtime. `source-hashes.json` pins the tested production and regression sources.

The sole open PR at intake was #73, draft. Main merged cleanly into recovery. Publication used GitHub Git data APIs because terminal Git push lacks credentials; the produced remote trees were checked against local Git trees before updating the ref with an expected-head lease. No force push or PR merge was used.

## Regression and export

Official Godot 4.7.2 SHA-256: `cadd3204e728a35d3f13adb7fd0d7902636b79f6b95c40c265eb73b6c35329e4`. Official export-template archive SHA-256: `f298490b8d44d934be425a5a65a51bf15f422428b229a06a6e11d9ffea248011`.

Commands executed:

```sh
python3 scripts/sync_approved_assets.py
bash scripts/validate.sh
godot --headless --path . --script res://tests/review_navigation_sweep.gd
godot --headless --path . --script res://tests/review_unprotected_run.gd -- 0 451 --strategic
GODOT_SKIP_TEMPLATE_DOWNLOAD=1 bash scripts/build_web.sh
```

All **47 Godot phases, 11 Python tests and Node lifecycle checks pass**. Full validation includes real Viewport mouse/touch routing, held press/release, legendary expiry/cache, modal ownership, profile behavior, deterministic combat, navigation and the new secondary/cache regression. The secondary test adjusts settings and exercises an actual retry without writing a persistent user profile. Its XP assertions cover zero and exactly half of the level-1 threshold.

The final release PCK has **379 directory entries**, **31,856,368 bytes**, SHA-256 `d719313b3270936d8aa830d2f2c4155df543ed7fcca80ecee3f910b8437265b4`. Inspection verifies 19 original masters, all 37 approved icons and all 84 Clean Cut resources. Tests/review scripts and candidate art are excluded. `build.json` identifies the final runtime revision. A local generated `build/.gdignore` avoids importing previous exported icons during repeated exports; clean CI builds have no prior output.

The sandbox needs writable XDG data/config/cache and TMPDIR locations. The editor's ObjectDB snapshot directory was pre-created inside that local test-data root; test failures were not filtered out. Engine binaries were not patched. Local relocated Xvfb helpers and Mesa provide software OpenGL. These environment accommodations are not project or gameplay changes.

## Rendered evidence

`tests/capture_review.gd` produced 29 actual native staged states at each of three physical window sizes: **1280×720**, **915×412**, **390×844**. Godot's existing content scaling means the portrait canvas is 520×1125; physical output remains 390×844. The retained 19 JPEG images comprise 16 current captures and three baseline comparisons. JPEG encoding is for repository size; no content was painted, generated or cropped. Original PNG hashes and dimensions are in `captures.json`.

Representative comparisons:

| Flow | Before | After |
| --- | --- | --- |
| Gameplay HUD / Safe Spot | [Baseline](evidence/m0-ui/baseline-playing.jpg) | [Current](evidence/m0-ui/final-desktop-playing.jpg) |
| Pause | [Baseline](evidence/m0-ui/baseline-paused.jpg) | [Current](evidence/m0-ui/final-desktop-paused.jpg) |
| Build inspection | [Baseline](evidence/m0-ui/baseline-build.jpg) | [Current](evidence/m0-ui/final-desktop-build.jpg) |
| Constrained settings | — | [915×412](evidence/m0-ui/final-landscape-options.jpg) |
| Portrait HUD | — | [390×844](evidence/m0-ui/final-portrait-playing.jpg) |
| Six legendary choices | — | [Desktop](evidence/m0-ui/final-desktop-legendary.jpg), [portrait scroll](evidence/m0-ui/final-portrait-legendary.jpg) |

These are **staged real renders**, not uninterrupted gameplay, human survival, browser WebGL2, physical-device metrics or owner visual acceptance. The latest creator-preferred prior playable revision remains unidentified; the baseline is the actual recovery parent, not an invented last-known-good build.

## Performance observations

`tests/review_recovery_performance.gd` measures seven staged fixed-seed scenes, each with 30 warm-up frames and 120 measured frames, using real `_process(1/60)`, skin refresh and native rendering. Seed 451, 1280×720, Compatibility, Mesa 25.2.8 llvmpipe LLVM 20.1.2. Dense fixture starts with 100 enemies. Boss fixture explicitly starts at the Berserk boundary with wave/boss/legendary state set to prevent a wave-transition modal from invalidating the measurement. No fixture is claimed as ordinary player progression.

The before/after measurements compare the baseline with initial recovery runtime `12d2f4d`; later XP-mask and caption-placement corrections are separately regression/render-tested, not silently included in these timings. Raw JSON includes mean, median, P95, P99, maximum frame times, script processing, skin refresh and actual end populations/mode. Native total-frame measurements include software rendering; script processing includes the native presenter and is not a pure simulation profiler. CPU and physical-device identity were not measured. No browser FPS is inferred.

| Scene | Skin refresh mean, before → after (ms) | Full frame mean, before → after (ms) |
| --- | --- | --- |
| Menu | 0.802 → 0.133 | 11.01 → 12.92 |
| Heroes | 1.048 → 0.127 | 12.36 → 12.61 |
| Opening combat | 0.693 → 0.157 | 7.73 → 8.87 |
| Dense combat | 0.898 → 0.169 | 16.85 → 15.25 |
| Upgrade | 0.994 → 0.111 | 10.03 → 9.26 |
| Legendary | 1.608 → 0.110 | 11.66 → 8.99 |
| Boss / Berserk fixture | 0.817 → 0.110 | 7.78 → 6.54 |

Skin refresh cost decreased in each scene. Total-frame timing is mixed on this shared software-rendered environment, so this is evidence for the localized optimization, not proof of universally higher FPS or fully recovered combat feel.

## Remaining acceptance

A fresh normal-health **scripted** Sigma 451 strategic run wins at 674.7167 seconds, preserving the historical scenario outcome. It does not replace normal human Web play or a recording. The static-cover sweep tests 2,048 trajectories without a reproduced stall; intentional ranged/telegraph states and experiential enemy behavior still require normal-play review.

GitHub reports successful automatic Vercel preview status for the initial runtime. A read-only deployment lookup failed with **403 forbidden** for team `pedroestrela6-8110`; no access rules were changed and no manual deployment/share link was created. Vercel READY/status success alone is not Web interaction validation. No working browser session, real multitouch device, uninterrupted normal-play video or final creator visual verdict is claimed.

The open wave-transition crystal/direct-XP discrepancy and all remaining M0 gates are recorded in [RECOVERY_STATUS.md](RECOVERY_STATUS.md). This checkpoint is reviewable implementation, not completion of the full M0.0 directive.

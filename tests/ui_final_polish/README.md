# M0 final UI corrections — creator review

Base: `fix/m0-navigation-ui-recovery@7b5ca519df06cc7e33e01720e1e2b361acfa1112`, the verified PR #89 merge. Its tree is identical to reviewed `03f26b1`; `main@bc69061` does not contain this UI. The four referenced creator screenshots were not attached. Controlled before captures therefore use the verified integration source. **Draft only; no merge or production deployment.**

## Runtime evidence

| Review | Actual Godot output |
| --- | --- |
| Boss behind status; separately, boss clipped by viewport | [Matched before/after](evidence/combat-before-after.jpg) |
| Centered live Boss HP / Berserk | [Boss](evidence/boss-hp.jpg) |
| Entire charging / READY ring, matched crops | [Flex](evidence/flex-charge-ready.jpg) |
| Content-sized Settings | [Before/after](evidence/settings-before-after.jpg) |
| Landscape, synthetic asymmetric safe insets | [Mobile](evidence/mobile-landscape.jpg) |
| Equipped/empty title and icon spacing | [Actual Build crop](evidence/build-alignment.jpg) |

Only six evidence images. Desktop is 1600×900; requested mobile 844×390 reads back as 843×390. Composites/crops contain unaltered native captures at matched scale, with added labels. Profiles use defaults and disable saving. These are controlled fixtures, not human play, browser permission tests or physical-device performance evidence.

## Findings and correction

The isolated near-HUD boss intersects player status while fully inside the viewport. The separate corner fixture intersects status **and** clips at the camera edge. [Recorded bounds](evidence/validation.json) distinguish them; matched corner position, attack line, camera projection and RNG are identical before/after.

Only covered decoration becomes translucent. Decorative hero identity temporarily yields; HP/Shield and other essential values keep tight contrast surfaces. Equipment and the Flex body also yield where necessary; the interactive Flex ring, text and hit target remain intact. A single contextual boss arrow/name appears in free terrain. `EDGE` describes actual clipping, not a fabricated threat position. Actual hostile line/arc boundaries are clipped to covered HUD regions and re-exposed above decoration, below essential text. Danger geometry follows current camera/tracking each rendered update; actor overlap checks are capped at 20 Hz. HUD geometry/assets stay cached. No camera, actor, AI, spawn, collision, timing or RNG changes.

Flex reserves eight logical units for its maximum existing READY rays, preserving the 164/184-unit target. Boss HP reuses the existing angular navy/gold nameplate, exact approved single-frame Big Hater crop, red live fill and Berserk copy in 82 rather than 88 logical units. No source image changes.

Settings height follows actual columns/content (430 rather than 468 logical units in the desktop run fixture). The volume target is 64 units. Browser Fullscreen now uses the same **already integrated secondary candidate** normal/hover/focus/pressed PNGs, nine-slice proportions and Archivo weight as native controls, with the existing trusted gesture/denial/retry path. Existing OFL is packaged. Reuse does not promote candidate art into approved registries. Build receives status padding and a 16-unit status/title gap. Native Pause inspection found no defect requiring a redesign; existing actions/confirmation remain unchanged.

## Verification and limits

[Eight targeted suites](evidence/targeted.json) · [six-viewport/five-state checks](evidence/checks.json) · [small CPU guard](evidence/cost.json) · [capture/provenance](evidence/validation.json).

Actual Godot tests cover live HP, all hostile shapes, clipping versus HUD overlap, safe insets, empty/full equipment, pointer/keyboard Settings persistence, Pause/Quit, joystick/multitouch, Reduced Motion and unchanged irregular-frame simulation/RNG/camera hashes. Node tests cover trusted fullscreen, denial/retry, focus/pointer faces, modal ownership and CSS/DPR invariants. Final mandatory CI/Web export results are recorded on the PR.

The 100-actor headless CPU guard measures the added presentation work, **not FPS**: timings are recorded separately for 20 Hz actor checks and live boundary updates. It does not establish a mobile frame budget. Physical Pixel 8a/Brave and browser gameplay QA remain pending. Natural camera-edge clipping remains signaled; this task does not claim the earlier mobile stutter is resolved.

Changed runtime files: `hero_clash_{hud,threat_overlay,flex_dial}.gd`, `clean_cut_{skin,secondary}.gd`, `web/platform.js`, `scripts/build_web.sh`. Validation changes: the Draft CI allowlist, `scripts/validate.sh`, HUD/fullscreen tests and this review directory. Gameplay source, camera, save schema, fonts, approved artwork/manifests and historical evidence are unchanged.

Reproduce native captures: `godot --path . --rendering-driver opengl3 --script res://tests/ui_final_polish/capture.gd -- 1600 900 /tmp/ui-final near-hud,clipped,boss,charging,ready,options,build,paused`; use `844 390` and `mobile` for the landscape fixture. Review evidence/tests are excluded from production exports.

The initial full CI caught inherited panel padding enlarging contextual Labels. Zero-margin contrast surfaces now preserve their reserved rectangles; new assertions wait for deferred layout, and the unchanged six-viewport recovery audit passes. Only affected captures were refreshed for the correction.

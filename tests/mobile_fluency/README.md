# Mobile fullscreen and touch frame cost — PR #82 follow-up

Baseline: `6af2a5348eff9b7e23e336a4f37d5c21ab44a779`. Same recovery branch; original #80/#81 artwork, controls, balance and profiles remain intact.

## Confirmed causes and changes

- Joystick direction/center/active state were part of the entire Clean Cut layout signature. Changing direction rebuilt the HUD's fonts, style overrides and geometry. The two live joystick sprites now update independently before the signature early return; HP/Shield, Aura, choices, focus and responsive geometry retain their existing invalidation. Actual touch drag/release tests cover all six GDD viewports and prove no drag-triggered rebuild, no RNG use and live ring/thumb updates.
- The previous browser adapter listened only for bubbling `pointerup`, tried once, and never recovered after rejection/exit. The new adapter listens in capture phase for trusted canvas `pointerup` and `touchend`, invokes the browser request synchronously before awaiting anything, and keeps explicit retry available through FULLSCREEN in menu/pause/settings. It never cancels gameplay input. Utility controls are hidden over combat, hero/upgrade/replacement choices, confirmations and results, avoiding footer/touch ownership conflicts. Actual fullscreen state comes from the document; exiting does not trap the user into immediate re-entry.
- The official Godot 4.7.2 Web template multiplies adaptive canvas dimensions by full devicePixelRatio. At 844×390 CSS pixels / DPR 3 the baseline raster was 2532×1170. Mobile raster density is now capped at 1.5, producing 1266×585 (75% fewer pixels in that example). Desktop DPR and low-DPR mobile are retained. The Web preset uses manual canvas resizing with one JavaScript owner. Godot's logical layout uses CSS dimensions independently of framebuffer pixels, preserving control sizes and camera composition across DPR values.
- The adapter loads during HTML startup, including before WebGL initialization, instead of depending on a late Godot callback. Safe-area metrics are event-cached, so the 0.5 s engine poll no longer forces DOM style reads. Resize, fullscreen and page restoration refresh them.
- Safari on iPhone does not provide arbitrary-element Fullscreen API. The honest fallback is Home Screen standalone launch: a same-origin `display: standalone` manifest, Apple web-app metadata, and FULLSCREEN HELP. No service worker/offline cache, forced browser setting, renderer change or fake fullscreen-success state is introduced. Supported browsers enter fullscreen after an eligible user gesture; navigation to a URL alone cannot grant browser fullscreen permission.

Official references: [Godot Web input/fullscreen restrictions](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html), [MDN transient activation](https://developer.mozilla.org/en-US/docs/Web/Security/Defenses/User_activation), [WebKit iPhone API limitation](https://bugs.webkit.org/show_bug.cgi?id=206854). The raster behavior was also inspected directly in the SHA-verified official 4.7.2 export template. The 1.5 cap is our performance/clarity tradeoff, not a guarantee of device FPS.

## Measured evidence

Same-host Godot 4.7.2 **headless CPU** fixture, 180 direction updates; no rendered FPS claim:

| Measurement | Before | After |
| --- | ---: | ---: |
| HUD update median | 3,877 µs | 58 µs |
| HUD update p95 | 10,214 µs | 166 µs |
| Full layout rebuilds | 180 | 1 |

[Before log](evidence/profile-before.log) · [After log](evidence/profile-after.log) · [Real touch regression](evidence/touch-tests.log).

The profile also records 20/100-enemy AI CPU and cold/warm animation-frame costs. Those paths were not changed in this follow-up. This does not establish phone frame pacing, GPU time or that every cause of stutter has been eliminated.

`tests/test_web_platform.cjs` verifies capture registration, TouchEvent fallback, trusted activation, duplicate-event suppression, refusal/retry, exit, prefixed API, orientation denial, iOS help/standalone, modal visibility, six viewports, DPR 1/1.5/2/3, desktop preservation and cached metrics. `test_drag.gd` checks actual Godot touch events and CSS/DPR control-size parity. Both are part of the complete regression suite; no existing assertion is weakened.

Reproduce with `node tests/test_web_platform.cjs`, `godot --headless --path . --script res://tests/mobile_fluency/test_drag.gd`, `godot --headless --path . --script res://tests/mobile_fluency/profile.gd` and `bash scripts/build_web.sh`. The final PR description records final-commit CI, protected preview and actual browser-test results. Physical Android/iPhone QA remains required; this cloud browser previously lacked WebGL2 and cannot establish game fluidity on a phone.

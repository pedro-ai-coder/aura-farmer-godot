# Threat indicator recovery — M0 creator review

Baseline: production `05bcef23ae0f040795cacd88e42542b55bc6488e`, tree `f0563ca6dfe764b4090b9beb4f00dc0a2f3b939b`, verified through Vercel deployment/build metadata and the green [last PR #90 CI](https://github.com/pedro-ai-coder/aura-farmer-godot/actions/runs/41138163613). The creator confirmed Pixel 8a fluidity across five waves and the final encounter on that version. This is physical acceptance of that tested build, not measured FPS or blanket Android validation. New-build device regression remains pending.

## Runtime correction

The existing overlay now shows only canonical names. Fully visible and insignificantly clipped bosses do not receive a decorative label. Fully off-screen active bosses remain represented, rather than disappearing beyond the old 32-unit visibility guard. One reusable arrow/name is selected deterministically: eligible Big Hater first; otherwise retain the current relevant event, then use stable IDs. A recovering secondary threat cannot briefly flash during priority handoff.

Visibility uses the renderer's trimmed-frame/pivot/pose bounds, the actual camera-to-safe-UI transform and cached permanent HUD rectangles. This is conservative geometric coverage, not an alpha-pixel or line-of-sight measurement. Less than 60% readable area enters a contextual cue after 180 ms; recovery to at least 78% requires 300 ms. At most 12% viewport visibility enters the off-screen classification, which persists until more than 32% returns; classification switches require 200 ms. Lower-priority ownership handoff has a 160 ms guard. Existing actual hostile boundary strokes remain live between the 20 Hz visibility samples and independent of cue suppression.

Small movements retain the current free anchor. The entire marker avoids safe insets, permanent HUD, the player, the current joystick and Legendary action. There are no new animations or input-owning controls. Ordinary enemies no longer incur unnecessary sprite-bound scans for boss labels. The already-fixed permanent HUD remains opaque and visible: **no fading, hidden portrait/name, replacement styles, moved HUD or camera adjustment**.

Only `scripts/hero_clash_threat_overlay.gd` changes runtime behavior. No gameplay, camera, speed, combat, RNG, asset, font, save, browser adapter or renderer source changed. Source snapshots/hashes are in [validation](evidence/validation.json).

## Actual Godot evidence

- [Matched desktop before/after](evidence/before-after.jpg): slight clipping, real HUD occlusion and fully off-screen Reply Guy; world state/camera/RNG match.
- [13-second real-engine recording](evidence/indicator.mp4) · [frame/state transitions](evidence/recording.json). Actual Godot Movie Maker, 1280×720, offline fixed 30 fps, controlled actor trajectories. This is neither a human full run nor delivered/browser/device FPS evidence.
- Full mobile examples: [HUD occlusion](evidence/mobile-occluded.jpg), [Big Hater priority](evidence/mobile-priority.jpg), [actual attack boundary](evidence/mobile-telegraph.jpg), [owned joystick plus actual second-finger Sigma Flex](evidence/mobile-mobile-input.jpg).

| Requested viewport | All ten state overviews | Full native-size off-screen example |
| --- | --- | --- |
| 1920×1080 | [Overview](evidence/gallery-1920x1080.jpg) | [Full](evidence/offscreen-1920x1080.jpg) |
| 1600×900 | [Overview](evidence/gallery-1600x900.jpg) | [Full](evidence/offscreen-1600x900.jpg) |
| 1280×720 | [Overview](evidence/gallery-1280x720.jpg) | [Full](evidence/offscreen-1280x720.jpg) |
| 915×412 | [Overview](evidence/gallery-915x412.jpg) | [Full](evidence/offscreen-915x412.jpg) |
| 844×390 | [Overview](evidence/gallery-844x390.jpg) | [Full](evidence/offscreen-844x390.jpg) |
| 390×844 | [Overview](evidence/gallery-390x844.jpg) | [Full](evidence/offscreen-390x844.jpg) |

Sixty native frames were rendered with official Godot 4.7.2 Compatibility/X11/Mesa llvmpipe. Overview sheets resize/letterbox actual frames; selected full-size images retain native readback, including the 843×390 compact rounding. Compact fixtures use explicit synthetic asymmetric insets. Fixtures use isolated defaults with saves disabled. No generated imagery or altered source artwork. Raw frame hashes, exact readbacks, actor positions and reproduction inputs are retained in the metadata. The committed fixture recreates raw PNGs.

## Verification

[Eight targeted suites](evidence/targeted.json) · [threshold, priority and six-viewport cases](evidence/checks.json) · [paired component CPU comparison](evidence/paired-cpu.json).

Tests exercise fully/slightly/meaningfully clipped and HUD-covered bosses, completely off-screen bearing, boundary jitter, separate entry/exit/switch clocks, stable placement, multiple events and final-boss priority, recovering-owner handoff, dead/spawning actors, unchanged live attack geometry and simulation snapshots, all six safe layouts, Reduced Motion and pause/resume/result/restart. Existing HUD identity, input/multitouch, local-profile, layout and irregular-frame/RNG/camera regressions remain intact. The former `EDGE` assertion now checks canonical copy; existing HUD assertions were not removed. The baseline overlay is an exact test-only snapshot excluded from exports.

The paired CPU test uses both implementations against the same 100-actor live fixture with warm caches and steady cues. It measures sampled visibility and the unchanged live-boundary path separately; see exact medians/P95/P99. It does not measure rendering FPS or physical Android performance. Full mandatory CI, official Web export and the protected preview are recorded on the PR's exact final head. No merge or production deployment is authorized.

Reproduce: `godot --headless --path . --script res://tests/threat_indicator/test_indicator.gd`; native stills: `godot --path . --rendering-driver opengl3 --script res://tests/threat_indicator/capture.gd -- 1600 900 /tmp/threat visible,slight,clipped,occluded,offscreen,multiple,priority,big-hater,telegraph,mobile-input`. Recording: `godot --path . --resolution 1280x720 --write-movie /tmp/threat.avi --fixed-fps 30 --script res://tests/threat_indicator/record.gd -- /tmp/threat-record`. The engine records the movie before ordinary H264 encoding; the recording JSON lists every state change.

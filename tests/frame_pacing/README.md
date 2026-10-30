# M0 mobile frame pacing recovery — device gate pending

The targeted collision CPU bottleneck is reduced. **The Pixel 8a / Brave stutter is not certified resolved.** Native software-rendered frame delivery remains variable, including dense-combat stalls. LDPlayer and physical Android were unavailable; no device measurements are inferred.

Baseline: `f6034fcb61c56f9ba3af083238cc673583028c34`, PR #82, including merged #83 and its dependencies. This review stays stacked on #82 to preserve its Hero Clash HUD. Main's separate technical consolidation (#85, `bc69061`) does not approve the inherited candidate artwork. This PR changes no source artwork, approval register, font, gameplay balance or profile format.

## Implemented correction

Repeated floor-boundary work dominated dense enemy simulation. The immutable Ruin Alley polygon now caches its edges and a conservative cell-center clearance certificate (12.5 KB). By the distance triangle inequality, certified interior points can skip the repeated edge loop. Uncertain points execute the original exact ray/clearance test. Cover checks, radii, axis order, spawn attempts and RNG consumption are unchanged. Zero movement axes skip a redundant collision query.

The paired 32,768-call geometry benchmark fell from **284.704 ms to 107.464 ms median (62.3%)**, over ten alternating trials. This is CPU work, not rendered FPS. Full irregular-frame state/RNG/event/camera hashes match the pre-optimization reference; 388,512 differential floor/cover/axis comparisons pass.

The existing `_process` scheduling, 1/60 maximum substep, 0.25-second cap and camera follow are preserved. Larger deltas multiply enemy work; the fix reduces that work rather than changing elapsed-time semantics. Camera execution is small relative to navigation/rendering in this environment; no camera architecture change is justified by these measurements.

## Comparable measurements

Godot 4.7.2 Compatibility, X11/Xvfb, Mesa 25.2.8 llvmpipe software renderer, 60-frame cap. Native fixture window: 1266×585; readback: 1265×585; logical layout: 1125×520. The 1.5 raster ratio emulates resolution workload, **not an Android device or browser**. The reported ViewportTexture size differs from readback, so both are recorded separately.

Two alternating before/after runs replay the identical seeded irregular simulation trace, with 240 rendered frames per scenario (movement stops at four simulation seconds). This isolates workload while measuring actual native `frame_post_draw` intervals. Simulation time is independent of wall time in these controlled replays. Timings include all samples, cold frames and stalls; phase timings are nested and must not be summed. Separate elapsed-time runs retain the ordinary scheduling feedback.

| Scenario | Render P95 ms before / after | Render P99 ms before / after | Simulation median ms before / after |
| --- | ---: | ---: | ---: |
| idle | 26.59 / 24.11 | 45.05 / 32.30 | 0.086 / 0.063 |
| movement | 29.03 / 29.58 | 52.51 / 43.26 | 0.097 / 0.074 |
| reversals | 25.35 / 25.24 | 39.02 / 34.98 | 0.091 / 0.072 |
| normal | 35.58 / 29.28 | 80.65 / 35.16 | 0.391 / 0.314 |
| dense | 49.68 / 50.14 | 69.77 / 65.66 | 2.886 / 2.157 |
| flex | 39.28 / 30.36 | 51.70 / 48.46 | 0.955 / 0.703 |

Dense P95 **did not improve consistently** across trials; the CPU gain is not proof of sustained frame pacing. Lower raster density reduced GPU work on this software renderer without reliably eliminating long frames. No permanent quality reduction was applied. Enemy membership, HUD rebuilding, new animation textures, weapons/projectiles, camera and platform costs are separately observable; the measurements do not identify a universal Android bottleneck.

Fixtures: quiet idle; four-second straight movement; reversals/diagonals; normal early combat with the real starter/spawner; wave-five combat initially at the canonical 100-enemy limit with a legal Alpha build and normal HP; actual Flex activation with 24 enemies. No invulnerability or reduced entity limits are used. See [metrics](evidence/metrics.json), [raw samples and logs](evidence/raw-measurements.zip), and [validation](evidence/validation.json).

## Runtime evidence

- Movement: [before](evidence/before-movement.mp4) / [after](evidence/after-movement.mp4).
- Dense combat: [before](evidence/before-dense.mp4) / [after](evidence/after-dense.mp4).
- Matched HUD: [desktop before](evidence/hud-1280x720-before.png) / [after](evidence/hud-1280x720-after.png); [compact before](evidence/hud-844x390-before.png) / [after](evidence/hud-844x390-after.png).
- All six requested viewports produced **pixel-identical** matched before/after images: [sizes and hashes](evidence/visual-parity.json). Some compact native readbacks round one dimension down by one pixel; this is recorded, not relabeled as the requested size.

Videos record actual native presentation with routed scripted touch and real elapsed simulation time. The external X11 recorder samples at 30 fps; this is **not engine FPS**, human testing or device validation. Recording adds observer overhead and is separate from benchmarks. Capture metadata accompanies each movie. The PNG/VFR fallback recorder is also available but its slower readback captures are not the delivered movies.

## Device review and diagnostics

The protected preview uses **Web Performance Review**, with diagnostics inactive by default. Add `?perf=1&perf_device=Pixel8a-Brave`. Play, pause, then choose **DEV · PERF REPORT → DOWNLOAD JSON**. Nothing is uploaded. The normal `Web` export excludes the recorder and its JavaScript entirely; real PCK directory checks enforce this.

The report buffers at most 3,600 samples: browser rAF intervals/long tasks; engine render intervals; simulation/substeps; player, enemy, weapon/projectile, hazard/passive, HUD, camera, platform and drawing costs; entity/effect counts; world travel/positions; viewport/readback/GL drawing-buffer dimensions; DPR, UA and available renderer information. This renderer uses immediate effects and no particle nodes. Zero/unavailable render/GPU counters become null. Headless results never claim FPS.

Input timing begins at engine receipt of the oldest unanswered owner event, using the latest requested direction; browser event-dispatch delay is separate. Response requires displacement along that direction or a stop. Blocked/unanswered input is not fabricated as a latency sample. These are not hardware-to-photon measurements.

The default recorder uses phase totals. `&perf_detail=1` enables per-actor navigation/membership clocks for diagnosis; all controlled before/after data used this detailed mode. The paired overhead sample was roughly 9.4% for detailed timing; phase-only timing was within host noise (0.2% paired median). Neither is an Android overhead guarantee. Raw overhead trials are included. Ordinary gameplay installs no recorder.

`&perf_raster=1` (also 1.25 or 1.5) is a reversible diagnostic cap, available only with `perf=1` in the review export. It retains CSS layout and input coordinates. The ordinary compact-touch cap remains 1.5. Compare both builds on the same device/browser/version, orientation, fullscreen state, hero and scenario; keep cold and warm samples distinguishable. Browser brands may not expose an exact Brave version; record it alongside the JSON.

Desktop Chrome, LDPlayer Chrome and physical Android Chrome/Pixel 8a Brave remain required comparison targets. Their measurements and comfortable physical-device playability are **pending**. Green CI and native captures do not clear this gate.

## Reproduction

Sync approved assets and import using the repository's existing scripts. Run `bash scripts/validate.sh` with fresh isolated user data. The evidence run executed all 62 Godot phases with separate temporary user-data directories, plus Node checks and 11 icon-pipeline tests. Eight affected Godot phases were repeated after separating phase/per-actor diagnostics. Both official Web exports pass asset, font-license and diagnostic-isolation checks.

```bash
# No rendering FPS is reported by the headless CPU comparison.
python3 tests/frame_pacing/run_comparison.py /tmp/pacing-cpu --frames 600
# Run with an actual X11 display; GODOT_COMMAND can be a JSON argv wrapper.
python3 tests/frame_pacing/run_comparison.py /tmp/pacing-native --native
# Elapsed native scheduling instead of the controlled trace:
godot --path . --script res://tests/frame_pacing/measure.gd -- /tmp/pacing-live 844 390 180 1.5
# Movie capture, separate from benchmark timing:
xvfb-run -a python3 tests/frame_pacing/record_x11.py /tmp/pacing-video --scenario movement
```

Preserved: canonical three-hero speed, floating full-playfield joystick, independent Flex finger, #82 touch fast path, fullscreen, DPR budget, keyboard input, pause/resume, collisions, IDs/saves and all approved art hashes. No approved files require supersession. No merge, release or artistic approval is claimed.

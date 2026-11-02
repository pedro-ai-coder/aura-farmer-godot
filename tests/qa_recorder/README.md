# QA recorder validation

Baseline: production `dc07b5fe721bd89dee783384a69e36af820e280a` (PR #101).
No canonical gameplay, art or GDD numerical changes. Review code lives under `qa/`;
ordinary exports exclude it and use the original main scene.

## Creator entry

See [the four-step recording/export guide](../../qa/README.md). The protected preview
is linked from PR #103. Start QA is explicitly opt-in. Record video externally.

## Reproduce

Use Godot 4.7.2 Compatibility, import approved assets first:

```sh
python3 scripts/sync_approved_assets.py
godot --headless --path . --import
godot --headless --path . --script res://tests/qa_recorder/test_recorder.gd
godot --headless --path . --script res://tests/qa_recorder/normal_run.gd -- 0 451 --strategic
python3 tests/qa_recorder/check_export.py
godot --headless --path . --script res://tests/qa_recorder/measure.gd
```

Local preview scene: `godot --path . res://qa/main.tscn`. `qa/build.json` is generated
by the Web exporter; without it local metadata explicitly reports an unknown SHA.
`QA_REVIEW=1 bash scripts/build_web.sh` selects the isolated Web QA preset. Only
`qa/real-gameplay-recorder` automatically opts its Vercel **preview** into that
preset. Production with QA enabled fails before export. Pack inspection checks
both presence in review and absence in ordinary exports.

## Evidence and limits

- `evidence/contracts.log`: 2,160 exact state/RNG/profile comparisons, three kits,
  six appearances, irregular frames, pause/resume, real committed upgrades,
  invalid-choice rejection, event/boss boundaries, outcomes, retry, ZIP and caps.
  Boundary cases deliberately set clocks; they are contract tests, not normal runs.
- `evidence/sample-session.zip`: actual canonical normal-health simulation under
  the existing strategic bot policy, seed 451, Sigma. It loses at 154.7 active
  seconds, level 8, 125 kills, 711 collected XP. No invulnerability, XP/damage grants
  or clock jumps. Automated and accelerated, **not human gameplay**. Explicit
  fixture sampling adds half-second simulation samples for inspecting the schema;
  its frame timing must not be interpreted as rendered FPS.
- `evidence/performance.json`: three alternating paired native headless repetitions,
  180 steps at 60 Hz, forced 2 Hz sampling; ordinary and 90-enemy controlled scenes.
  Latest median repetition mean CPU cost: 43.21 → 50.26 µs ordinary;
  890.48 → 687.78 µs dense. Dense p95: 1,780 → 1,226 µs. The apparent dense
  improvement is VM/run-order noise, **not an optimization claim**. An earlier
  pairing measured 639.85 → 685.73 µs dense. Includes callback hooks and polling;
  excludes renderer/browser/GPU. No physical Pixel 8a performance claim.
- `evidence/ui.log`: control-signal opt-in/mark/export/clear, pause/input preservation
  and bounds at 1600×900 / 844×390, tested headlessly; no visual acceptance claimed.
- The protected Web export completed and passed the QA resource pack check. Its
  `build.json` returned HTTP 200 and matched its exact deployed commit.
- Cloud browser reached the preview but reports missing WebGL2. Web gameplay and
  trusted-click ZIP download therefore remain **unverified in that browser**.
  A creator test in a WebGL2-capable browser is still needed; it is not replaced
  by the native ZIP contract test.

Do not merge or deploy to production. This instrument collects evidence for the
pacing audit; it does not approve any pacing configuration.

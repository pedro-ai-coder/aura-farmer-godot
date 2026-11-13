# Hero animation recovery follow-up

**Partial recovery, Draft; not ready for merge or final visual acceptance.**
Runtime commit: `908392f3ce5fb14054da9c4b22ecb0e4147fe49d`.
Art-blocker specification: `e8d6c2b` (no asset changes).
GDD V3 and the creator decision register remain operational.

## Baseline and scope

Continues [Game PR #132](https://github.com/pedro-ai-coder/aura-farmer-godot/pull/132)
from `f9b2d3a7e06693557ff9bd773d62bca007e079c7`, on its existing branch
`feat/approved-six-hero-motion-2026-11-13`. [PR #125](https://github.com/pedro-ai-coder/aura-farmer-godot/pull/125)
head `b5ec5979eac7ad24ac4af461972caaaa537be27a` is an ancestor. All existing
recovery commits are retained. No branch history was rewritten.

Fetched main: `2298e39ab727a88defd7c421f95969f30a422212`, also the deployed
production SHA previously verified in the existing recovery report. This run
renders that exact Git source as the production reference; it does not reverify
the live hosted deployment. The branch lacks main's later context-routing and
build-preflight commits; their relevant routing guidance was read with `git show`
without merging unrelated work. Runtime source remains independently reviewable.

The three requested creator MP4s are absent. None was inspected. Existing #132
captures and fresh native production/before/after comparisons are the available
visual evidence; parity with the inaccessible approved recording is unproven.

## Completed corrections

| Component / exact files | Original issue and correction | Verification / limitation |
| --- | --- | --- |
| `scripts/solo_run.gd`, `scripts/weapon_presentation.gd` | A stationary left attack reverted to an old rightward travel latch when recovery expired. Retain the latest valid horizontal attack bearing through rest/vertical travel. Later horizontal displacement supersedes it. Reset and cancellation discard invalid history. | All six identities, 30/60/120 Hz targeted cases, eight steering headings, native recovery assertions. No render-order state, input easing, gameplay facing, attack deadline or save change. |
| `scripts/approved_hero_motion.gd`, `scripts/weapon_presentation.gd` | Legacy stage grips put muzzle flashes/key accents away from the new embedded equipment. Measure run/portrait source anchors for Sigma, Pixel Vixen, Cool Kid and Byte Baddie, apply current scale/pivot/mirroring and bounded torso influence. | Pixel Vixen pilot captured and inspected first, then shared pattern verified. No second prop/body, new drawings or texture edits. Source geometry justifies distinct run/portrait anchors. Tiny arm motion inside the eight run cells remains authored in the images. |
| `tests/test_locomotion_runtime.gd` | Missing recovery-orientation/vertical-history coverage. Extend the existing fixture with all headings, cancellation, reset, rate independence and registered effects. | Executed PASS; standing and moving attack, hurt/Flex gait, collision-slide and Reduced Motion regressions remain covered. |
| `tests/capture_hero_presentation.gd`, `tests/record_approved_hero_motion.gd` | Native evidence lacked persistent left recovery and a continuous combat movie. Extend existing matrix and recorder; add optional `--combat` using the existing weapon fixture. | Matrix uses durable stationary targets and explicit hurt/Flex/defeat setup. Restored a target after Flex before testing left attacks, and assert the expected orientation. The separate ordinary movie uses normal early gameplay. Neither fixture represents human acceptance. |
| `tests/frame_pacing/state_trace.gd` | Opaque golden failure. Print expected/actual hashes, engine and viewport on failure. | Golden file is unchanged and the mandatory check still FAILS. |

The five requested appearances share the repaired orientation system. Sigma also
benefits and remains the sixth stable appearance. Alpha/Block Queen retain the
existing shield/gauntlet artwork and combat timings; no missing shield/strike
choreography is claimed fixed. All three kit IDs, source image hashes, speeds,
weapons, RNG, progression, collision and persistence formats remain unchanged.

Source authority: existing `hero-motion-v3/approval.json` and manifest; Canon
`CPK-ART-THREE-HERO-SOURCES-2026-11-12-01`. Source approval does not approve this
runtime animation quality. Exact CPK provenance and historical manifest status
are reconciled in [the separate application specification](cpk-application-spec.md).
**Zero new exact CPK applications were integrated; all five remain blocked.**

## Executed validation and evidence

Godot `4.7.2.stable.official.ed1daf0bf`, official engine ZIP SHA-256
`cadd3204e728a35d3f13adb7fd0d7902636b79f6b95c40c265eb73b6c35329e4`.
Official templates verified against the build script's pinned checksum. Native
renderer: Compatibility / Xorg / Mesa llvmpipe. Separate import caches were used
for final baseline/candidate comparisons.

- `bash scripts/validate.sh`: **FAIL** at `frame-pacing-state`. The unchanged
  subsequent commands were then executed separately. **82/83 Godot phases PASS**,
  including all remaining phases, exact weapon parity (3,456 comparisons),
  profile/save, progression/RNG, roster/selection/Retry, motion, HUD and assets.
  Python/Node prerequisites and remaining asset checks passed. An initial attempt
  during active edits crashed at HUD V2; its isolated repeat and the complete
  stable-source attempt passed. That failed attempt is not counted as passing.
- Full normal/dense/Flex trace hashes match at pre-optimization `f6034fc`, #132
  `f9b2d3a` and runtime `908392f`. For the old checkout, only the same external
  trace/setup harness was supplied; its runtime was unchanged. Per-field binary
  hashes also match all 360 frames in each scenario. The frozen golden is not
  reproducible even with the original runtime in this environment. Its original
  capture conditions remain unresolved; replacing it would be unjustified.
- Official local Web export of **908392f** passed resource/provenance/isolation
  checks. Its `build.json` reports that exact full SHA and engine 4.7.2. Chromium
  exercised all six live selections, actual keyboard movement/reversal and sent
  pause/resume input: zero page/console errors; screenshots inspected. No hosted
  deployment, physical-mobile measurement or mobile Web touch test is claimed.
- [Production / previous recovery / follow-up](followup-evidence/production-comparison.webp),
  [paired before/after](followup-evidence/before-after.webp),
  [six-appearance matrix](followup-evidence/six-appearance-matrix.webp),
  [Web identities](followup-evidence/web-six-appearances.webp).
  Images retain native 180px gameplay crops; matrix rows are Sigma, Cool Kid,
  Alpha Chad, Pixel Vixen, Byte Baddie, Block Queen. The final matrix column is
  the actual defeat/results screen, not a fabricated defeat drawing.
- [24-second native combat movie](followup-evidence/controlled-combat.mp4),
  720 encoded frames, 1280x720, 30 Hz simulation. Segments are four seconds per
  appearance in the same order. Every segment contains real queued stationary
  and moving attacks, with advancing run frames. Durable stationary targets are
  synthetic; no invulnerability or gameplay balance changes were added. The
  separate ordinary gameplay movie was also recorded and sampled locally;
  [its contact sheet](followup-evidence/normal-gameplay.webp) identifies all six.
  Encoding was decoded at six timestamps and metadata inspected. Movie cadence
  is not a performance benchmark.

Details: [validation JSON](followup-validation.json),
[performance JSON](followup-performance.json),
[evidence checksums](followup-evidence/evidence-sha256.json).

## Performance and open acceptance gates

Three alternating isolated native `--mobile-regular` trials, seed 451,
844x390, 25 initial enemies, 30 warmup + 180 measured frames each:

| Trial | Before / after render-loop p95 (ms) | Before / after pose median (microseconds) |
| --- | --- | --- |
| 1 | 20.713 / 21.949 | 28 / 30 |
| 2 | 21.158 / 22.410 | 29 / 30 |
| 3 | 21.550 / 22.384 | 28 / 30 |

The follow-up adds 1–2 microseconds to median descriptor CPU time; this fixture's
render-loop p95 is 0.83–1.25 ms higher. This is a measured difference, not a claim
of zero regression or of a causal GPU cost. It does not certify device pacing,
display-presented FPS, input-to-photon latency or performance in every kit.

The existing [pose dependency brief](art-dependencies.md) remains applicable:
registered ready/start/stop transitions; ranged firing arms/recovery; Keyboard
Warrior first/second strikes and CTRL + CHAOS; shield/gauntlet brace, slam and
countershock; hurt, character-specific Flex and defeat. Preserve 512px cells,
`(256,464)` registration and the 70-world-unit body. Eight steering headings are
not eight authored body directions; rear/backpedal/vertical aiming need approved
drawings. Current portrait-to-run silhouette changes and missing full-body
choreography remain visible. No premium parity or artistic completion is claimed.

The exact approved CPK master is missing from the checked Art revisions and
workspace. Transparent emblem exports, per-frame wearable applications and
24/48/96px exact-emblem legibility remain **BLOCKED/NOT_RUN**. Existing painted
letters are not evidence of the exact approved broken-ring emblem.

## Review and rollback

Ready to review: the two concrete engineering corrections and native comparisons.
Not ready for merge: frozen-state gate, missing authored poses/CPK source, final
creator animation acceptance and real-device performance. Review exact candidate
art in the existing Art/Canon workflow before any runtime promotion.

Rollback engineering with `git revert 908392f3ce5fb14054da9c4b22ecb0e4147fe49d`.
Revert the separate CPK specification commit independently if needed; neither
operation changes source artwork. Evidence/report commits have no runtime effect.
No merge, production deployment, release or paid service was performed.

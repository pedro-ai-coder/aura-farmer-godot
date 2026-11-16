# Cool Kid articulated v2 — creator review candidate

**CANDIDATE / NOT ARTISTICALLY APPROVED.** This replaces the rejected pilot
for review, not approved production artwork. Game #151 and Art #32 remain
Draft. Canon #43 remains decision authority; no new canon decision is inferred.
No merge, deployment, production promotion, gameplay or other-hero rollout.

## Play and review

The local deliverables are under `build/cool-kid-v2/`:

- `CLUTCHPUNKS-CoolKid-candidate-web-20261116.zip`: self-contained playable Web
  export, current approved Neon Garage, six identities, default Cool Kid.
- `ab.mp4`: **24 seconds, 1280×720, 30 fps**, ordinary camera and health. Actual
  F8 input toggles at 6/12/18 seconds. Legacy: 0–6 and 12–18; candidate: 6–12
  and 18–24. Movement includes all eight headings, diagonals, reversals,
  start/stop, stationary/moving attacks and hurt.
- `flex.mp4`: **35.367 seconds**, actual normal run from canonical time 90 to
  125.35. Hurt starts at 92.883; earned Flex enters at 97.600, loops at 97.850,
  exits at 102.350. This is 7.600/7.850/12.350 seconds into this movie.
- `defeat.mp4`: **8.267 seconds**, stationary normal-health run from canonical
  time 90. Death occurs at 96.750. The unchanged approved results screen
  immediately replaces the world; a labelled QA inset samples the **live
  canonical defeat clock** for 1.5 seconds. It injects no state or damage.
- `inspection.mp4`: **32 seconds**, eight source views, joint markers and
  enlarged state windows, with legacy/candidate at normal scale alongside.
  **Synthetic diagnostic, not ordinary-gameplay proof.**
- `CoolKid-v2-editable-art.zip`: SVG/ORA masters, original source, retained
  pixels, authored surfaces, exporter and immutable manifest/hash inventory.

Unzip the playable build, then run `python3 -m http.server 8765` in that folder
and visit `http://127.0.0.1:8765/`. Do not open Wasm through a `file:` URL.
No hosted preview was published. The review profile is disposable and does
not save. WASD/arrows move, attacks remain automatic, existing Flex input is
unchanged. F8/the review button changes only the renderer. Reduced Motion
uses the approved renderer with an explicit fallback reason.

Reproduce with the official Godot 4.7.2 editor and official Web templates:

```sh
GODOT_BIN=/path/to/Godot_v4.7.2-stable_linux.x86_64 bash scripts/build_cool_kid_review.sh
/path/to/godot-4.7.2 --path . res://scenes/neon_cool_kid_review.tscn
# Native display and ffmpeg required; sequential captures use localhost:9876.
DISPLAY=:99 GODOT_BIN=/path/to/godot-4.7.2 bash scripts/capture_cool_kid_motion.sh ab
# Other supported sequences: flex, defeat, inspection.
node tests/cool_kid_rig/browser_review.cjs /absolute/output/folder
```

## Immutable sources

| Source | Exact reference |
| --- | --- |
| Approved Game main / frozen parity control | `2f7cfab5d0b498a2d7dade97ec1adf38e58fda50` |
| Initial rejected review branch | `f405e5d791cc0923ce9e314690d3baeee70be067` |
| Final implementation and QA source | `50cbbf7acd07563226c332301260b14822fbe7e8` |
| Consumed Art candidate | `e4f4a43fc166dea6bb9cea494e3c09e445f35811` |
| Candidate manifest SHA-256 | `53dfcae7594fe940d4a1c7f36254ef3e99a9a25a98b1ea1aabb07f353507c022` |
| Approved source atlas SHA-256 | `6f91466b63ebf3c80a427533b1d051e6b80df04654c5bd3ab318315234456bf2` |
| Canon #43 authority read | `c3d75557bf24b965a0c15041042aa57840313494` |

The creator's exact 20.5-second, 1910×902/30fps video was downloaded and
inspected at ordinary scale and in sequential frames. Its input hash is in the
[artifact record](art/evidence/cool-kid-rig-v2/artifacts.json). The pasted request
is instruction authority; the recording is evidence, not instructions.

## Audit and implementation

The prior direction predicate admitted only E/SE/S of the eight principal
headings. Five sectors silently selected legacy while the label still said
candidate. The old 22% stance, weak source-pixel body offsets and limited
arm/prop hierarchy made the A/B difference slight. This was a rejected
front/three-quarter spike, not completed production animation.

The existing immediate CanvasItem architecture is retained. Schema-v2 rig
manifests carry eight independent source views and the same 16-part hierarchy.
Each source view is an existing approved merged-main drawing; original face,
beanie lettering, hood, sleeve emblem and prop pixels retain their identity.
Original source PNGs and v1 masters remain untouched. New arm/hand anatomy,
trouser/ankle/sneaker contours, cuts and hidden surfaces are explicitly
**candidate artwork**. Rear heels and sleeve ownership are authored per view;
no original lettering or keyboard is reflected.

`cool_kid_motion.gd` centralizes authored action knots. The existing renderer
adds distance-driven alternating contact/recovery, two-bone legs, world-space
contact anchors, contact compression/passing rise, pelvis/torso counter-motion,
head stabilization and delayed pompom motion. Right-arm IK follows the shared
palm/keyboard chain. Rear arms/prop pass behind the jacket with the correct
sleeve in front. Startup/stopping blend over 75ms; view changes use a 75ms
presentation dissolve. Defeat collapses the connected hierarchy about the
ground, rather than rotating only the torso over standing legs.

All action inputs remain canonical attack/hurt/Flex/defeat clocks. No movement
speed, hitbox, weapon timing, damage, content ID, save, RNG or controller code
changes. `solo_run.gd`, `hero_animation.gd` and `signal_breaker_garage.gd` are
byte-identical to approved main. Only the isolated review coordinator hides
its own HUD in Options; approved menus and result presentation are preserved.

Textures and decoded hashes are prepared once. Normal frames perform no image
processing or texture loads. View data, draw orders and authored state curves
are cached. The legacy renderer remains opt-in/default/reduced-motion/invalid
package/unsupported-identity or state fallback. The review HUD names the actual
condition; all eight Cool Kid movement views stay candidate. New QA evidence
is `.gdignore`d and explicitly excluded from every export preset. The generated
`build/` directory is also ignored/excluded; PCK checks reject both prefixes.

## Iterative visual corrections

Real native frames and ordinary gameplay exposed defects that numerical pose
checks did not: cutout fragments at wrists, exposed rear neck, front/back arm
ordering, misplaced rear sleeve ownership, frontal laces on rear shoes and
inward knee solutions. These were corrected in focused source/art commits,
then the native sequences were recaptured. The final knee solution bends away
from the body centre in front/rear views and forward in side views; this removes
the hanging/crossing knee silhouette seen in the intermediate captures.

Only `ab.mp4`, `flex.mp4`, `defeat.mp4` and `inspection.mp4` in the final artifact
record are final evidence. Older `cool-kid-*` filenames in the working build
folder are intermediate/superseded and are not delivery proof.

## Actual technical results

Official engine: `4.7.2.stable.official.ed1daf0bf`, Compatibility, Linux x86_64,
Xorg dummy display, Mesa 25.0.7 llvmpipe; Chromium 151.0.7922.173/SwiftShader.
The initially installed 4.6.3 was not used to claim validation. Editor archive
SHA-256 `cadd3204e728a35d3f13adb7fd0d7902636b79f6b95c40c265eb73b6c35329e4`;
official template archive SHA-256
`f298490b8d44d934be425a5a65a51bf15f422428b229a06a6e11d9ffea248011`.

Commands below use that editor as `$GODOT_BIN`. Logs are in
[the evidence directory](art/evidence/cool-kid-rig-v2/).

| Gate / actual command | Result |
| --- | --- |
| Art `python3 export.py`, repeated | **PASS**: 426 generated files byte-identical; eight SVG/ORA masters and 128 source/RGBA hashes pinned |
| `python3 scripts/verify_cool_kid_rig.py` | **PASS**: all eight views, 128 PNGs, parent order, dimensions, RGBA/file hashes, manifest pin and lossless imports |
| `$GODOT_BIN --headless --path . --import` | **PASS**, official 4.7.2, no script/import errors |
| `--script res://tests/cool_kid_rig/test_rig.gd` | **PASS**, 480 state samples, package/fallback/identity/reduced-motion and grip contracts |
| `--script res://tests/cool_kid_rig/test_motion.gd` | **PASS**, 5,760 eight-view/state samples, finite transforms, knee/ankle continuity and palm overlap; 748 stable world-contact comparisons, zero reach releases in the straight eight-direction fixture |
| `--script res://tests/cool_kid_rig/test_neon_preview.gd` | **PASS**, Neon/six identities/default Cool Kid, gameplay, Options HUD exclusion and pure F8 toggle |
| Normal run, legacy and candidate | **PASS**, seed 468, 7,521 frames, 125.35s, 93 kills, earned Flex and 139 hurt frames; identical `0983db4e4e922027247b93205e7ea704e8da78d346f031de1f6277b65af8b647` |
| Native normal/F8/Flex/death captures | **PASS executed**, actual rendering, normal HP and canonical events; no injected enemies, damage, aura or invulnerability |
| `GODOT_BIN=... bash scripts/validate.sh` | **FAIL**, retained historical `baseline_states.json` gate |
| Same historical state gate on frozen approved main | **FAIL**, same pre-existing historical mismatch; no golden edited |
| Frozen main `state_trace.gd -- --record <outside-fixture-control.json>`; candidate `--expected <same>` | **PASS**, normal/dense/Flex full state/RNG/event/camera hashes identical |
| `GODOT_STATE_REFERENCE=<frozen-control> GODOT_BIN=... bash scripts/validate.sh` | **PASS**, all 86 Godot phases plus Python/Node/asset gates. Final art/occlusion refinements then repeated affected import/rig/Neon/parity/export/native/browser checks |
| `GODOT_BIN=... bash scripts/build_cool_kid_review.sh` | **PASS**, review Web export includes final candidate and hashes validate |
| `--export-release Web ...`; verifier with `--production` | **PASS**, ordinary PCK contains no Cool Kid candidate resources |
| Real Chromium `browser_review.cjs` | **PASS**, exported Wasm/pinned decoded hashes, observed Garage/selection/gameplay/F8/pause/Reduced Motion; no browser/script/HTTP errors |
| Reduced Motion | **PASS**, real Settings toggle and visible explicit legacy fallback; no new rig motion |
| Native frame-pacing measurement | **EXECUTED**, three alternating paired trials, 120 measured frames each, no image readback/video capture. See `performance-isolated.json`; median trial frame time 11.875ms legacy / 13.436ms candidate, P95 38.438 / 38.845ms. Pure sample median 56µs; software host is not device certification |
| Sustained 60fps / physical target devices | **FAIL on this software host / NOT_RUN on target devices**; do not infer a mobile performance pass |

The frozen-main supplemental control is a comparison artifact, never a new
historical baseline. Full-suite completion predates final presentation-only
refinements; targeted final checks and actual captures validate those changes.
Normal gameplay evidence is automated play, not a human playtest. Movies sample
the actual runtime at canonical playback speed; they are offline rendered frame
sequences, **not proof that this host delivered real-time 30/60fps**. Performance
is measured separately without capture readback. Captures are silent (Dummy
audio driver); game audio code is unchanged.

## Visual review and remaining limits

The difference to review is an alternating articulated stride, coordinated
weight, coupled wrists/keyboard and full directional continuity at the real
camera. The enlarged inspector exposes joints rather than replacing that
acceptance target. Mathematical constraints are not artistic approval.

| Visual gate | Observed result / creator decision still needed |
| --- | --- |
| Gaps, detached limbs/prop, joint contour | Wrist fragments and knee-side errors corrected after real frame review. No obvious normal-camera disconnection in final sampled footage; inspect the new vector/raster joins closely |
| Planted feet | Zero early reach releases in the A/B run; one protective reach release in late normal/Flex play near constrained traversal. This is disclosed, not a universal no-slide PASS |
| Knee folding/intersection | Final front/rear/side bend polarity corrected and inspected in footage; new trouser contour still requires artistic review |
| Direction/view transitions | Eight distinct views, no directional fallback; short dissolves can show a faint double contour during a reversal |
| Attack, hurt, Flex, defeat | Distinct body/prop performances on canonical clocks. Facial expressions remain those of the source directional drawings; no new complete set of action facial paintings was authored |
| Identity/style | Original head/lettering/hood/emblem/keyboard retained; new vector limbs and sneakers need approval for style match |
| Extreme deformation | Rigid parts and constrained IK, no runtime squash or texture deformation; candidate overlap/pose appeal remains reviewable |
| Normal-scale readability and A/B quality | Final real-camera footage supplied. **Creator APPROVED / NOT APPROVED is pending**, not inferred from tests |

This is a concrete playable candidate for that decision, **not a declaration
that every visual gate or production-quality acceptance has passed**. Suggested
review response: APPROVED / NOT APPROVED, plus timecode, view/state and the
specific silhouette/contact/acting issue. No other scope is reopened.

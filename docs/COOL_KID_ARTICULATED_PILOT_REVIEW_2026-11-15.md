# Cool Kid articulated pilot — verified intermediate, NOT production complete

## Review location and exact sources

The local Web export is `build/cool-kid-review/index.html`, served in this
execution environment at http://127.0.0.1:8765/. This is not a published URL or
a guaranteed port-forward to the creator's computer. Download/copy the local
review ZIP or reproduce it with Godot 4.7.2 and its official Web templates:

```sh
GODOT_BIN=/path/to/Godot_v4.7.2-stable_linux.x86_64 bash scripts/build_cool_kid_review.sh
python3 -m http.server 8765 --bind 127.0.0.1 --directory build/cool-kid-review
```

Native source entry (same gameplay controller, disposable profile):

```sh
/path/to/godot-4.7.2 --path . res://scenes/cool_kid_review.tscn
```

Choose **Hero Selection → Original → Cool Kid → Start Run**. Movement uses the
existing WASD/arrows, attacks remain automatic and Flex uses its existing input.
F8 or the review button switches candidate/legacy without restarting simulation.
The isolated entry never writes profile saves. Other heroes remain available as
identity controls. Ordinary production builds exclude candidate textures and
manifest. The native opt-in on the ordinary entry is `-- --cool-kid-rig-review`;
the isolated review entry enables its candidate explicitly.

| Source | Immutable reference |
| --- | --- |
| Unchanged Game main control | `0007cb62aca84e6af8a1018c82b684199c7e8cdb` |
| Tested Game implementation tree | `c0956bfe6b9229f969111bc93af5760a7057bfc1` (subsequent commits add evidence/docs) |
| Art main base | `6b0da4f4cee5a72caec3c12b87c3e5817d94f969` |
| Canon main base | `a1e670ff889b1a804a9c8b97b755e433a5cf3c95` |
| Consumed Art candidate | `5ba1bfb24624d5c84f7d9994ebb719986b43871c` |
| Consumed manifest SHA-256 | `748e327c37c8743d827b5ecff79dfb781455477bc11644caa86ef75132e51b24` |
| Canon #43 decision read | `1942c5fad9d1adee72ec95f6838ac74bf2da1106` |
| Art #30 handoff read | `cb3bcf591abebfcca4d35e81f55ed2f3c976f737` |
| Art #29 defect reference read | `c377c7729769177cc164ca9a72592e7b468f2254` |

Game production Draft: https://github.com/pedro-ai-coder/aura-farmer-godot/pull/150.
Art production Draft: https://github.com/pedro-ai-coder/clutchpunks-art-pipeline/pull/32.
Canon implementation receipt Draft: https://github.com/pedro-ai-coder/clutchpunks-canon/pull/45.
Canon pilot-direction Draft remains https://github.com/pedro-ai-coder/clutchpunks-canon/pull/43.
Neither documentation draft is assumed merged. Game #137–#148 were inspected as
unmerged dependencies and were not edited, rebased or made prerequisites.
GitHub identity and push permission were verified as `pedro-ai-coder` for all
three repositories. Bounded Canon GDD V4 and inherited V3 rules remain authority.

## What actually changed

The exact approved portrait is decomposed into 16 exclusively owned pixel
regions. Original face, beanie, clothing, CPK lettering and keyboard pixels are
retained; each source pixel belongs to one visible layer. NEW CANDIDATE vector
underpainting provides hidden neck, sleeve, elbow, pelvis, knee, ankle and prop
underlaps. Editable SVG, OpenRaster, per-layer preserved PNGs, hidden-surface
SVGs and deterministic export source are retained in Art. This is low-resolution
194×292 source preservation, not a newly painted high-resolution character.

The renderer samples existing `hero_animation.gd` state precedence and canonical
time/distance. A parent transform hierarchy couples arms, hand and keyboard,
with two-bone knee solving, level sneakers, torso/head counter-motion and delayed
pompom. Attack uses anticipation/strike/recovery knots within the existing
0.22-second visual flash. Flex samples its existing ages and remaining time.
No controller, hitbox, weapon timing, damage, AI, RNG or save implementation was
changed. The actor matches the current 64-pixel atlas height.

Compared with HTML #29, there is now real in-engine playback, exclusive source
ownership, authored underlaps, a parented keyboard, knees/feet, cached textures,
immutable decoded-pixel validation and tested fallback. This does **not** prove
that every old cutout defect is fixed or that the motion is production quality.

## Executed validation

Environment: Linux x86_64, 3 vCPUs (AMD EPYC 9V74 host), Mesa llvmpipe software
OpenGL, Xorg dummy display 1280×720; Chromium 151.0.7922.173 with SwiftShader.
Godot `4.7.2.stable.official.ed1daf0bf`. Official editor archive SHA-256
`cadd3204e728a35d3f13adb7fd0d7902636b79f6b95c40c265eb73b6c35329e4`;
Web template archive SHA-256
`f298490b8d44d934be425a5a65a51bf15f422428b229a06a6e11d9ffea248011`.
The initially installed Godot 4.6.3 was not used to claim validation.

Evidence below is relative to `docs/art/evidence/cool-kid-rig-v1/`.

| Command / check | Actual result and evidence |
| --- | --- |
| Art `python3 export.py` repeated | PASS; 54 PNG/SVG/JSON/ORA hashes identical, RGBA transparency and exact source portrait/sheet hashes; Art validation record |
| `python3 scripts/verify_cool_kid_rig.py` | PASS; 16 file/RGBA hashes, parents, pinned manifest, lossless import settings |
| `godot --headless --path . --script res://tests/cool_kid_rig/test_rig.gd` | Exit 0, PASS; 480 sampled poses, attachment, identity, reduced-motion, invalid/missing package, direction/state fallback; `rig-contract-final.log` |
| `godot --headless --path . --import` | Exit 0, no script errors, performed by final review builder |
| `GODOT_BIN=... bash scripts/validate.sh` | Exit 1 at historical frame-pacing golden; `validate.log`; do not call this PASS |
| Same historical state test on untouched frozen main | Exit 1, same historical-golden failure; `base-historical-gate.log` |
| Frozen main `state_trace.gd -- --record <outside-repo-control>` followed by candidate `--expected <control>` | Both exit 0; normal/dense/Flex hashes identical; `base-trace.log`, `candidate-trace.log`, `frozen-main-states.json` |
| `GODOT_STATE_REFERENCE=<frozen-main-states.json> GODOT_BIN=... bash scripts/validate.sh` | Exit 0; all 81 Godot phases and Python/Node gates completed; `validate-frozen-control.log`. This supplements, never replaces, the failed historical golden |
| `normal_run.gd` with and without `--candidate` | Both exit 0; seed 468, 7,521 frames / 125.35 simulated seconds, 93 kills, earned Flex, 139 hurt frames, identical hash `0983db4e4e922027247b93205e7ea704e8da78d346f031de1f6277b65af8b647`; normal logs |
| Native `normal_run.gd -- --candidate --native-evidence <output>` | Exit 0; same hash as headless normal run. Real rendered idle/run/attack/hurt/Flex-loop/out captures; `native-normal.log`, native WebP captures |
| Native guided keyboard/mouse session | Real menu/selection, movement, F8 A/B and pause exercised with X11 events. Agent-guided, **not a human playtest**; local recording retained |
| `GODOT_BIN=... bash scripts/build_cool_kid_review.sh` | Exit 0; actual Web export, imported candidate PCK resources and approved source packs verified; `build-final.log` |
| Ordinary `--export-release Web` plus `verify_cool_kid_rig.py <pck> --production` | Exit 0; candidate assets/manifest excluded; `production-exclusion.log` |
| Chromium via Playwright, actual exported Wasm | Menu, mouse hero selection, movement, F8 A/B and pause/resume; pinned candidate valid in browser, zero JS/console runtime errors, all recorded requests HTTP 200; `web-results.json`, `web-play.webp` |

No historical golden file was edited. Its underlying drift remains unresolved;
matching this session's untouched main proves this renderer did not introduce
that drift. Existing suite covers profile compatibility and six identities;
no new profile schema or character IDs were created.

## Actual visual evidence and defects

`state-board.webp` is native Godot A/B rendering at 3× gameplay size, synthetic
state samples, legacy left/candidate right. It is not a combat recording.
`native-attack.webp`, `native-hurt.webp` and `native-flex.webp` are from the actual
seeded normal run at respectively 20.68, 92.88 and 98.23 simulated seconds,
with the candidate confirmed active. `native-normal-excerpt.mp4` is the first
12 seconds of real X11 recording, normal playback rate, no synthetic effects.
The full local video records the first 140 wall-clock seconds, **not** the whole
335.95-second observed native run; later hurt/Flex proof is in the real captures.
Older local files named `native-final.mp4` predate the final height correction
and are superseded, not final-build proof. Hashes are in the evidence manifest.

| State/direction | Observed coverage / remaining defect |
| --- | --- |
| Idle | Independent breathing/head/pompom; original identity retained. Limited menu personality; menu/selection still uses approved static art |
| East / southeast / south run | Real joint playback. Knee silhouette and cloth overlap can look pinched; ankle reach clamps and diagonal/downward contacts can slide. No quantitative no-slip acceptance |
| West / northwest / north / northeast / southwest | Existing atlas fallback. No candidate rear/left master; transition can visibly pop |
| Stop/start/turn | Immediate canonical response retained; settling and view-switch blending are unfinished |
| Attack | Prop transform is attached; limited swing arc, source bent arms remain restrictive, no independently painted striking hand poses |
| Hurt | Actual real-hit pose captured; smiling source face does not express pain convincingly |
| Flex in/loop/out | Actual earned Flex ran; entry can be fallback at unsupported heading. Too little pose contrast/torso drive versus desired full-body action |
| Defeat | Diagnostic board only; torso tilt over upright legs is insufficient. No normal-run defeat validation |
| Neck/shoulder/elbow/waist | Added underlaps remove exposed unpainted surfaces in sampled front poses; not certified across larger motion ranges |
| Hand/keyboard | Exact parent transform tested; no free-floating independent prop transform. Grip pose and second-hand independence still need artwork |
| CPK text | No reflection, exact source lettering retained |
| Reduced motion | Contract fallback passed; full visual browser walkthrough NOT_RUN |

The package is **not ready for final artistic approval**: missing directional
masters, leg contour/foot-slide defects and weak attack/hurt/Flex/defeat posing
remain material. This is a verified playable intermediate, not fulfillment of
the brief's production-quality definition of done.

## Performance and checks not run

The 7,521-frame headless normal run took 3,112.251 ms with sampled rig versus
2,592.948 ms with legacy disabled in that measurement (observer CPU/wall totals,
not a GPU frame benchmark). Real native rendering took 335,953.157 ms for
125.35 simulated seconds under software rendering and capture contention.
Chromium RAF sample during actual play: 12 intervals, median 275 ms, p95/max
533.3 ms (`web-frame-metrics.json`). This is poor pacing on this environment,
not a production performance pass or a measured regression against matched
GPU baselines. Per-frame allocation profiling and a representative GPU/mobile
performance comparison are NOT_RUN. Browser resource timings are recorded raw.

NOT_RUN: human playtest; real-browser earned hurt/Flex, defeat/results/retry
walkthrough; independent rear/left rig art; full eight-heading seam/no-slip
acceptance; production hardware performance; final artistic sign-off.
The advertised shared-desktop viewer returned “Cloud Desktop requires a thread
with an available Cloud environment” despite a ready environment. No forwarding
tool was available, so native QA used local Xorg, and browser QA used Chromium.
This did not prevent the executed tests; it prevents promising a creator-visible
live desktop link.

## Rollback and one artistic decision

F8 immediately selects the existing atlas renderer. Outside review, omit
`--cool-kid-rig-review` / the Web query opt-in. Use the ordinary main scene and
Web preset to exclude candidate art; production PCK exclusion was tested. Remove
or revert the independent implementation commit to remove the adapter. Close
unmerged drafts independently; no protected branch was changed. Approved source
art, gameplay/RNG/save code and unrelated UI stacks remain intact.

The only pending artistic decision is **approve or reject the exact candidate
rig appearance and motion**, including its newly authored hidden pixels.
Existing approved source sheets must not be reapproved. Given the defects above,
final artistic approval is not recommended yet. Merges, deployments and release
remain separately unauthorized; none were performed.

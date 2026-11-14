# Creator-approved individual sheets — game integration

Decision `CPK-HERO-SHEETS-INTEGRATION-2026-11-14-01`, 2026-11-14.

The creator explicitly approved the six sheets shown in the individual-sheet
gallery and instructed: **“Estes assets estão aprovados. Integra-os no jogo de
uma vez por todas!”** This is approval of these exact assets and authorization
to integrate them. Standing authorization permits scoped merges when no further
creator intervention is needed. Do not request approval of these same sources
again or infer approval of future/redrawn artwork.

Exact source Art commit: `52c8618098c68034f42ec469567effc952cfdb27`.
Sources are retained unchanged under
`assets/production/heroes/individual-sheets-v1/*/approved-source.png`.
The pack manifest records source hashes and all technical derivative hashes.

## Resulting behavior

All six identities use the new approved visual sources in the home preview,
Hero Selection, HUD, results and live gameplay. The same three canonical kits,
appearance preference, save IDs, attack/Flex events, balance and RNG remain.
Textures are cached strongly. The rejected Pixel Vixen CPK v1 atlas is not
loaded or shipped in the new Web build; its historical source remains on disk.

Approved poses drive lifecycle playback with presentation-only transforms.
No new independently authored inbetweens or complete eight-direction animation
set is claimed. Front/back drawings cover opposite headings without reflecting
CPK lettering. The original sheet labels are not re-encoded or repainted.
Where the three-quarter caption touches the drawing, the unused display slot
and portrait use the already approved idle drawing, recorded in the manifest.

## Actual validation

- All **79** Godot validation phases completed successfully across the full
  suite and the rerun of the remaining phases after obsolete portrait assertions
  were updated. Python and Node preflight/asset checks also passed.
- All 24 source/atlas/portrait/HUD SHA-256 checks and 72 transparent atlas cells
  passed. These cells include a documented safe duplicate, not 72 newly authored
  unique animation drawings.
- The old frozen state comparison fails on untouched main too. The original
  fixture remains unchanged. A separate unchanged-main control at
  `a7695eb86a659fc8b9e065960aee0951ddfdb900` and the candidate produced identical
  hashes for all three 360-frame state/RNG/event/camera traces on Windows/Godot
  4.7.2. The scoped gate uses that source-main control on Windows; other platforms
  retain their historical gate. See `tests/frame_pacing/MAIN_BASELINE_PROVENANCE.md`.
- Actual native Compatibility/OpenGL rendering captured every identity in both
  selection and gameplay, plus compact and portrait views. This is renderer
  evidence, not an asserted GPU performance benchmark.
- The Web build passed its real PCK directory/resource checks. An isolated PCK
  loader resolved every atlas/selection/HUD texture and confirmed the rejected
  derivative and labeled masters are absent.
- A fresh headless Chromium session loaded the actual Web/Wasm game at 1280×720,
  selected Female using real mouse input, started Pixel Vixen and moved using
  the real D key. No browser runtime exceptions were observed. Native compact
  views were also captured; no mobile-device or cross-platform acceptance claim.
- A Windows-only path separator bug in the existing Clean Cut export verifier
  was corrected using `Path.as_posix()`. Its hashes and allowed-art policy are
  unchanged. All export verifiers then passed against the generated Web PCK.

## Merge, publication and costs

This integration is locally tested; remote CI is intentionally skipped with
`[skip ci]` to respect the no-cost instruction. `git.deploymentEnabled: false`
prevents the connected Vercel project from automatically publishing the source
push/merge. No remote build, release or deployment is requested by this change.
A separately authorized publication can restore that setting and deploy the
tested build. Local Web preview is available without publishing or paid services.

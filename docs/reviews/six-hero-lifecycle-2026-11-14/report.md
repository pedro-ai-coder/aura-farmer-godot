# Six-hero lifecycle motion candidate — 2026-11-14

**Partial engineering candidate, not a release candidate or production-parity acceptance.**

Runtime: `9542d48f641eb91b9186f8b5fcb9c7cca1d4a9af`.
Base: Game #132 `edf549ae9b7b0ccbcf6051a84345be05cdc007f5`, preserving #125
`b5ec5979eac7ad24ac4af461972caaaa537be27a` as an ancestor. Both remote heads
were checked. Remote main was `2298e39ab727a88defd7c421f95969f30a422212`.
No merge, production deployment, release or paid infrastructure.

## Changes and limitations

Six appearances share foot-anchored idle breathing, a 90 ms presentation-only
start/stop weight response, class-specific Flex envelopes, eased hurt feedback,
and a settling defeat deformation. The existing distance-driven gait, authoritative
attack stages, recovery facing and embedded equipment registration remain intact.
Reduced Motion suppresses these displacements. No simulation speed, collision,
kit, ID, RNG, save, attack deadline or image bytes changed.

This does **not** supply independent limb/action frames, eight directional art
sets, or interpolation between the standing portrait and run atlas. The original
portrait/run texture switch remains. Defeat is covered by the result UI in the
ordinary capture; the settled descriptor test is not proof of visible defeat
presentation. Flex offsets do not constitute authored class transformations.
Creator visual acceptance and physical-device performance remain pending.

## Source authority

GDD V3 and its decision register remain applicable, together with the limited
creator approvals recorded at Canon #39 `9e89f819b01c8247a917a1f35c0cf0d457c2a1d8`.
Art #22 head `025a962f7e883506381b27e26c7b4856a501141f` was fetched.
The original ZIP and unified style PNG were read from Git and verified:

- ZIP: `6faa385139a9306ceffae4c19d2a27e34399c2be4ee13fbb1c013162709ae043`.
- PNG: `f3f46b88f9586662f3dd27644fcfc862b36232e01851a00482790832536c564d`.

The Pixel Vixen strip was inspected as a motion reference. The bundle explicitly
contains annotated, inconsistent concept boards, not transparent runtime atlases.
It supplies no independently authored production action frames. Existing #132
images/provenance are preserved; this change does not claim to implement the
new unified apparel/CPK style board. No new asset is marked approved.

## Frozen-state investigation

The previous `/workspace/scratch/godot-4.7.2/preflight-report.md` was absent in
this fresh environment. Initially installed Godot was 4.6.3; validation used the
official 4.7.2 engine (`ed1daf0bf`), archive SHA-256
`cadd3204e728a35d3f13adb7fd0d7902636b79f6b95c40c265eb73b6c35329e4`.
Web templates matched
`f298490b8d44d934be425a5a65a51bf15f422428b229a06a6e11d9ffea248011`.

Read the latest QA triage on #132 and downloaded the logs of CI job
`124120222599`, run `41072583769`. Its passing checkout was the exact synthetic
merge **`89dfce7042faae1b4a03ece08037c4aad70a23aa`**, not simply a named branch.
That exact checkout was reproduced in an isolated worktree. Its project.godot
and measure.gd match #132 byte-for-byte; state_trace.gd differs only in failure
logging. Both the original unchanged check and #132 fail here with isolated
user data. Explicit CLI resolution 1280x720 did not change headless root size
(64x64) or hashes. No assertion or frozen hash was changed.

The supplied diagnostic harness adds per-field binary SHA-256 hashes after each
of the same 360 frames in normal/dense/Flex. Exact CI source, #132 base and this
candidate produce **identical 1,080-line traces**, including RNG, camera and all
KEYS entries. SHA-256 of each trace:
`ae2f914ae5560c30fdc88f535ef9baf946b908a65ab21bae8cb12ac384d8d4b8`.
Thus there is no first differing field/frame among these three local executions.
The historical passing run retained aggregate hashes, not field snapshots, so
its first divergent field cannot be recovered from that log. Serialization,
engine build, architecture and viewport/capture differences remain hypotheses.
Do not describe these comparisons as a root-cause fix.

Actual aggregate hashes in all local comparisons:

- normal: `d91735e4d6c1042fe731c8c8c775cf0a5781c9c498b905d5d1874a60b428b2b4`
- dense: `81965b18d1e560310f8ef8c630525ac11b745801c1ece7b4d1c37e983f9c95d3`
- flex: `3f235aff1150a52d56150f83ae02261d2e39bd47ada3cce60f0a55e4f5cd5060`

The mandatory gate remains **FAIL; merge/release blocked**. No gameplay correction
is justified by this evidence, so no speculative corrective PR was created.

## Graphics and evidence

Native Compatibility/Xorg with Mesa 25.0.7 llvmpipe starts successfully. Audio
hardware is absent; the repeat explicitly used Dummy audio. A separate Vulkan
probe reproduces missing `VK_KHR_surface`, then falls back to OpenGL. This is
an environment limitation, independent of the state-golden failure.

Native six-hero motion matrix and a 720-frame/24-second controlled combat movie
were captured with the existing fixtures. Durable targets are synthetic; this
is not human playtesting or FPS evidence. The matrix was inspected, including
Pixel Vixen's single body and embedded ranged effect. Movie encoding reports
slower-than-real-time recording; do not interpret capture rate as device FPS.
Large evidence stays in `/workspace/scratch/rc-motion`, outside Git.

## Validation and delivery

Validation summary is recorded in `validation.json`. Official local Web export
and packaged-resource/provenance/isolation checks passed. Export build.json pins
runtime `9542d48f641eb91b9186f8b5fcb9c7cca1d4a9af` and engine 4.7.2.
The local server uses port 8765. No claim of a hosted preview is made.

The Vercel connector verified the existing Hobby project
`prj_3LaQVHHdexAvm7ZFwAgOYdpu20jM`, team
`team_Qboo9LMxLe3dsTikfNtyDtIw`, with SSO protection enabled. Automatic approval
review rejected the explicit preview creation because authorization for sending
the private repository to that destination was considered insufficient. No
workaround or protection change was attempted. Hosted delivery needs explicit
creator confirmation for that exact project/preview payload.

## Reproduction and rollback

Use Godot 4.7.2 on PATH, then `bash scripts/validate.sh`. After the expected
frozen-state failure, execute the unchanged subsequent commands separately and
report them independently. Never edit the validator to skip the gate.
For the diagnostic, use `TRACE_OUTPUT=/absolute/output.jsonl godot --headless
--path <checkout> --script <absolute path to diagnostic_trace.gd>`; copy the
attached text fixture to a scratch `.gd` file first. It still exits nonzero on
the frozen mismatch and never writes the golden.

`GODOT_BIN=<4.7.2 executable> GODOT_SKIP_TEMPLATE_DOWNLOAD=1 bash scripts/build_web.sh`
requires the verified matching templates. Native fixtures:
`tests/capture_hero_presentation.gd -- <output> --motion-review` and
`tests/record_approved_hero_motion.gd -- <output.json> --combat` with
`--fixed-fps 30 --write-movie <output.avi>`.

Rollback the single runtime commit `9542d48` to restore #132 presentation.
No assets, profile migrations or server state require rollback.

# Animation fluency: approved composition and roster expansion

Source baseline: `5fd6c5780741e510874fc7f41de0b0037be15c87`, preview approved by the creator. QA report: https://github.com/pedro-ai-coder/clutchpunks-qa/pull/5.

The creator instructed implementation of the report, reviewed the concrete Cool Kid A/B, and explicitly approved expansion to the other five heroes on 2026-11-15. This records that bounded composition decision; it does not claim the complete 22-item backlog is finished or approve future artwork, merge or publication.

## Connection corrections

- Resolved displacement selects the visual moving/idle state. Held input into an obstacle no longer freezes a run pose. Movement/collision rules remain unchanged.
- Sigma holds a cap during windup and uses the authored empty-hand recovery pose after release. Baked airborne-cap drawings no longer compete with the real No Cap projectile during ordinary attacks. Original atlas PNGs and source studies are unchanged.
- Historical hero atlases are loaded only when explicitly requested for inspection. Active v2 preparation no longer pays their eager residency cost. Existing historical-resource checks remain valid.

## Cool Kid composition pilot

The original Cool Kid combines an existing upper action rectangle with front/back running legs at a registered packed-cell waist, y=142/192. Native inspection rejected an earlier y=120 seam because it retained hands from the run drawing; the calibrated seam excludes those hands. Gait phase remains distance-driven, including while attacking or using Flex; combat events/timing retain their existing owner. The selector `layered_locomotion_enabled` supports matched before/after captures.

This uses existing approved pixels without mirroring CPK, repainting, duplicated opacity blends, source changes or procedural inbetweens. It does not invent missing side-view attack art. After creator approval, the same approach is active for all six identities. Per-identity cuts in 192px cells are Sigma 142, Cool Kid 142, Pixel Vixen 144, Byte Baddie 136, Alpha Chad 138 and Block Queen 142. Higher cuts were rejected in native contact sheets because they retained displaced trouser/knee fragments. Attack legs use the authored front/rear view; Flex legs remain frontal because the source Flex torso drawings are frontal. The renderer does not invent a rear Flex torso. Stationary actions, hurt and defeat retain their authored full-body priority.

## Remaining scope

Eight-direction torso/weapon coverage, full per-frame hand/muzzle anchors, secondary motion, full dense-combat hierarchy, additional directional artwork and physical-device/human review are not completed by this pilot. The subsequent [combat feedback batch](COMBAT_FEEL_FEEDBACK.md) adds bounded event-driven audio, crowd-bar reductions and final cap/muzzle corrections with its own staged verification. These remain separate from final artistic acceptance. No merge or deployment is inferred from tests or the creator's earlier preview approval.

## Local verification

The complete existing validation command inventory plus the new regression ran as 105 independent checks, all passing, at `3d6049d`. This includes the historical state gate and separately recorded exact-main simulation/RNG/event/camera parity. After native inspection calibrated the seam to y=142 at `ad48596`, four focused checks passed again: animation fluency, six-identity atlas resources, canonical hero animation and weapon-presentation parity.

Native Movie Maker recordings compare the exact approved `5fd6c57` baseline against the calibrated pilot under identical fixed-step scripted input. A matched, enlarged side-by-side clip, original full-window clips, source checksums, logs and a review page remain locally in `animation-fluency-pilot-2026-11-15/`. Their 60-fps encoding is not a rendered-FPS benchmark. No performance gain or device certification is claimed for this pilot. This historical pilot was subsequently approved for roster expansion by the creator; the old approved Vercel deployment was not replaced.
